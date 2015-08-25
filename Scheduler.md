# Introduction #

Nuntium has a cron-like scheduler service which enqueues recurrent tasks in the job queue for later processing by the nuntium worker service, as processing capacity becomes available.

# Architecture #

The scheduler service is a ruby script that runs every X seconds (ideally 30) and checks for  tasks pending execution. Data regarding these tasks and their execution intervals and times are stored in a `cron_tasks` table. This service can be implemented as a windows service (for deploying under windows) the same way the nuntium worker is.

## Dependencies ##

The scheduler requires a visible endpoint in the queue service in order to be able to enqueue tasks instances whenever necessary.

## Sample tasks ##

Most AT channels are candidates to be implemented as tasks to be scheduled. Interfaces that require an active polling by nuntium may be cronned as well.

Some examples includes:
  * Twitter incoming messages
  * POP3 mail download
  * QST push/pull

## Table schema ##

The table containing the tasks data must have the following fields:
  * guid: unique identifier for the task
  * interval: ideal timespan between two consecutive executions
  * next run: when the next run should be enqueued
  * last run: when the last run was executed

There must also be a way for the task creator to identify the task. For example, when a task is created for a POP3 channel, the task must be deleted if the channel is deleted.

## Scheduler execution ##

Every time the scheduler runs, it checks the table for all tasks with a next run time less than or equals the current time. For each of these tasks, it enqueues a job for the nuntium worker and sets `nextRun = currentTime + interval`. Note that all tasks are wrapped with a cron task that interacts back with the cron service upon execution.

## Wrapper task execution ##

Whenever a task is executed, it must check its corresponding lastRun entry in the cron table. If `currentTime < lastRun + interval - tolerance` then the task is **dropped** and this event logged.

This has the effect of ensuring that two consecutive tasks will not be executed in less than `interval - tolerance` time.

## Task timeboxing ##

All tasks should be timeboxed to `interval / 2` to ensure there will be no overlapping (recall that last run time is set when the task starts, not when it finishes). This also prevents starvation in the job queue. Every task should check frequently if its time quota has not been exceeded, and if it has, terminate its operations in a clean way so its next instantiation will proceed from that point.

# Examples #

Standard execution flow for task A with 1 minute interval and cron every 30 seconds. This is the expected behaviour of the system, with little congestion in the queue so the timespan between enqueue and run is small. Note that at 1:32 A2 executes since 57 seconds falls within `interval - tolerance`.

| **MM:SS** | Event | nextRun | lastRun |
|:----------|:------|:--------|:--------|
| 00:00     | Initial state | 00:30   | -       |
| 00:30     | Cron enqueues A1 | 01:30   | -       |
| 00:35     | A1 begins execution | 01:30   | 00:35   |
| 00:45     | A1 ends execution | 01:30   | 00:35   |
| 01:00     | Cron executes | 01:30   | 00:35   |
| 01:30     | Cron enqueues A2 | 02:30   | 00:35   |
| 01:32     | A2 begins execution | 02:30   | 00:35   |


In this example the queue is rather full, being over a minute delay between enqueue and execution. Note how the difference `02:37 - 01:35` is kept so no tasks are dropped and A2 executes.

| **MM:SS** | Event | nextRun | lastRun |
|:----------|:------|:--------|:--------|
| 00:00     | Initial state | 00:30   | -       |
| 00:30     | Cron enqueues A1 | 01:30   | -       |
| 01:00     | Cron executes | 01:30   | -       |
| 01:30     | Cron enqueues A2 | 02:30   | -       |
| 01:35     | A1 begins execution | 02:30   | 01:35   |
| 01:38     | A1 ends execution | 02:30   | 01:35   |
| 02:00     | Cron executes | 02:30   | 01:35   |
| 02:30     | Cron enqueues A3 | 03:30   | 01:35   |
| 02:37     | A2 begins execution | 03:30   | 01:35   |


Now suppose A1 takes a long time before actually starting execution, while A2 does not. In this scenario A2 will be dropped since `02:03 - 01:35` is small, and A3 will be executed later.

| **MM:SS** | Event | nextRun | lastRun |
|:----------|:------|:--------|:--------|
| 00:00     | Initial state | 00:30   | -       |
| 00:30     | Cron enqueues A1 | 01:30   | -       |
| 01:00     | Cron executes | 01:30   | -       |
| 01:30     | Cron enqueues A2 | 02:30   | -       |
| 01:35     | A1 begins execution | 02:30   | 01:35   |
| 01:38     | A1 ends execution | 02:30   | 01:35   |
| 02:00     | Cron executes | 02:30   | 01:35   |
| 02:03     | A2 is dropped | 02:30   | 01:35   |
| 02:30     | Cron enqueues A3 | 03:30   | 01:35   |
| 02:56     | A3 executes | 03:30   | 02:56   |


This example is exactly the same as the first one but A1 consumes all its running quota and must terminate. Note that this does not affect A2 starting time, as last run is set upon execution begin.

| **MM:SS** | Event | nextRun | lastRun |
|:----------|:------|:--------|:--------|
| 00:00     | Initial state | 00:30   | -       |
| 00:30     | Cron enqueues A1 | 01:30   | -       |
| 00:35     | A1 begins execution | 01:30   | 00:35   |
| 01:00     | Cron executes | 01:30   | 00:35   |
| 01:05     | A1 forced to end | 01:30   | 00:35   |
| 01:30     | Cron enqueues A2 | 02:30   | 00:35   |
| 01:32     | A2 begins execution | 02:30   | 00:35   |