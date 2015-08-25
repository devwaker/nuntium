# Channels #

A channel lets Nuntium communicate with the world. By "the world" we mean anything that's not your particular application. For example: cellphone companies, email clients and twitter.

## Kinds ##

A channel kind defines the way it communicates with the world. For instance, if a channel sends messages via SMTP we say that its kind is SMTP.

## Directions ##

An **incoming** channel receives messages from "the world" into Nuntium so that later your application can receive them. In that way, it is _incoming from the point of view of your application_. These kind of messages are called [Application Terminated messages](Messages.md) because they terminate in your application.

An **outgoing** channel sends messages from Nuntium to "the world". Your application first sent those messages to Nuntium. In that way, it is _outgoing from the point of view of your application_. These kind of messages are called [Application Originated messages](Messages.md) because they are originated in your application.

A bi-directional channel is a channel that is both incoming and outgoing.

Examples of channel directions:
  * Incoming: POP3
  * Outgoing: SMTP
  * Bi-directional: a channel that communicates with a cellphone company.

## Protocols ##

You can have many outgoing channels in a Nuntium Application. A channel's protocol indicates which Application Originated messages are going to be sent via that channel.

For example, you might have an SMTP channel with a "mailto" protocol and a cellphone company channel with an "sms" protocol. If a message's "to" field is "[mailto://some@email.com](mailto://some@email.com)" it will be sent via the SMTP channel. If a message's "to" field is "sms://39569697" it will be sent via the cellphone company channel.

If you have more than one channel with the same protocol, [routing logic](Routing.md) is applied.

A message must always include a protocol in it's "to" field, otherwise a channel cannot be determined, even if you have a single outgoing channel.

## Pausing and disabling ##

When you pause a channel, messages can still be routed to it but they will not be sent until you unpause it.

On the other hand, if you disable a channel then:
  * Any queued messages in it will be routed to another enabled channel of the same protocol, if any
  * No new messages will enqueued in it (the channel will never be a candidate of the routing process)

## Channel Filter Phase ##

When an [AO message](Messages.md) arrives to Nuntium and has to be delivered through a channel, first a list of candidate channels is built. This list starts with all the account's channels and then:

  * Only outgoing enabled channels are kept.
  * Only channels for which the protocol is the same as the message's "to" field protocol are kept.
  * Channels that have restrictions that don't match the message's custom attributes are discarded.

## Channel Selection Strategy ##

Once a candidate channels list is built in the filter phase the application's strategy is applied:

  * **Broadcast**: the message will be sent through all candidate channels.
  * **Single (Priority)**: the message will be sent through the channel with highest priority (smallest number). If there are more than one channel with highest priority, a random one will be chosen.

The strategy can be overriden by specifying a [custom attribute](Messages#Custom_attributs.md) in the message.