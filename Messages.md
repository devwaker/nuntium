# Messages #

Nuntium is about sending and receiving messages

## Application Originated messages ##

Messages sent from your application into Nuntium and then into the world are called Application Originated messages. One of the most important fields of these kind of message is the "to" field, This field must be prefixed with a protocol in order to send it via a channel. [Read more about this](Channels#Protocols.md).

## Application Terminated messages ##

Messages sent from the world into Nuntium and then into your application are called Application Terminated messages.

## Structure of a message ##

A message consists of the following fields:
  * **id**: an autonumeric unique identifier
  * **guid**: a globally unique identifier that allows to relate messages originated in your application with messages in Nuntium. If your application sends a message with a guid, that same guid will be retained in the message that is stored in Nuntium. Otherwise a new random guid will be assigned to it.
  * **channel relative id**: an id assigned by the channel through which the message was sent or received. For example it might be the id twitter assigns to its messages.
  * **from**: who created the message? Must have a [protocol](Channels#Protocols.md).
  * **to**: who will receive the message? Must have a [protocol](Channels#Protocols.md).
  * **subject**: a short summary of the message. Can be blank.
  * **body**: the full text. Can be blank.
  * **timestamp**: when was this message sent/received?
  * **tries**: who many times this message was tried to be sent?
  * **state**: was this message sent successfully? Was there an error with this message? [Learn more...](MessageStates.md)

## Custom attributes ##

Besides the basic fields, any message can also contain any number of custom attributes. This is used for example in SMS messages to specify the "country" or "carrier".

These are the custom attributes reserved for Nuntium use:

  * **country**: Specifies the country for SMS messages. The value is the 2 letter ISO code of the [country](API#Countries.md).
  * **carrier**: Specifies the carrier for SMS messages. The value is the GUID of the carrier in the [Nuntium's carrier table](API#Carriers.md).
  * **application**: For AO messages, this is  the application where the message comes from. For AT messages, this attribute is specified during the execution of the AT rules and the application routing rules.
  * **strategy**: Overrides the default strategy used by applications when routing AO messages..
  * **suggested\_channel**: The name of a channel through which to route the AO message.

### Email Custom attributes ###

When sendings messages that will be sent via SMTP, custom attributes that start with `references_` will be sent in the `References` header. For example:

```
AOMessage:
  references_foo => 123
  references_bar => 456

Email:
  References: <123@foo.nuntium>, <456@bar.nuntium>
```

When receiving messages via POP3, references in the nuntium namespace (like `<xxx@xxx.nuntium>`) will be converted to `references_` custom attributes of AT messages.

Additionally, a `reply_to` custom attribute will be set with the GUID of the message for which the email is a reply to.