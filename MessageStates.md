# Message states #

A message can be in one of the following states:

  * **pending**: the message was received by Nuntium but it is still not queued for sending (not used at the moment)
  * **queued**: the message is queued in a channel and will be sent in a future
  * **delivered**: the message was sent, but Nuntium cannot be sure it was successfully sent by the real channel. For example a message could have been sent to an SMPP server but the server did not yet sent the message to the recipient user.
  * **confirmed**: the message was sent and a confirmation of this was sent by the real channel. For example a message would change to this state when an SMPP server tells Nuntium a previously sent message was successfully received by the recipient user.
  * **failed**: the message could not be queued (because the "to" field was missing a protocol) or the message could not be sent, or it was sent but the real channel told Nuntium that it could not send the message. This last case would happen when an SMPP cannot deliver a message to the recipient user.

The possible transitions are:
  * **pending** -> **queued**: when a channel was found to route the message
  * **pending** -> **failed**: when there is no channel to route the message to, or the "to" field was missing a protocol
  * **queued** -> **delivered**: when the message was sent via a channel
  * **delivered** -> **confirmed**: when the channel implementation confirms that the message was indeed sent and received by the target user
  * **delivered** -> **failed**: when the channel implementation says that the message could not be sent to the target user