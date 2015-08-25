# GUID and Channel-Relative ID #

AO and AT messages have the following columns: **id**, **guid** and **channel\_relative\_id**.

  * **id** is a number generated autonumerically by the database.

  * **guid** is a random guid generated by nuntium for AT messages or the guid field o AO messages that just arrived. This is expected to be globally unique.

  * **channel\_relative\_id** is the id given by a service like twitter or pop3 for AT messages. For AO messages it is an id generated by nuntium expected to match the service's id requirement if any, or the id returned by the service when it successfully receives the message. Otherwise it can be empty (for example in the QST case.) This id is expected to be unique relative to the channel, but collisions can happen globally.

QST is a special kind of channel/interface in that channel-relative ids doesn't make much sense to it.