# Advanced search #

You can use the syntax ```
key:value``` to perform advanced search operations, both on messages and logs. Following is a description of each search key.

## Messages ##

  * **id**:number - searches messages with the given id. [More about numbers](#Numbers.md)
  * **from**:text - searches messages with the given from field. [More about texts](#Texts.md)
  * **to**:text - searches messages with the given to field. [More about texts](#Texts.md)
  * **subject**:text - searches messages with the given subject. [More about texts](#Texts.md)
  * **body**:text - searches messages with the given body. [More about texts](#Texts.md)
  * **guid**:text - searches messages with guids that contain the given text.
  * **channel\_relative\_id**:text - searches the message with channel relative ids that contain the given text.
  * **state**:text - searches messages with the given state. State can be _error_, _failed_, _queued_, _delivered_ or _confirmed_.
  * **channel**:name - searches messages that are in the channel with the given name.
  * **tries**:number - searches messages with the given tries amount. [More about numbers](#Numbers.md)
  * **before**:date - searches messages that happened after the given date. [More about dates](#Dates.md).
  * **after**:date - searches messages that happened after the given date. [More about dates](#Dates.md).
  * **updated\_at**:date - searches messages that where updated at the given date. [More about dates](#Dates.md).


## Logs ##

  * **ao**:number - searches messages with the given Application Originated message id. [More about numbers](#Numbers.md)
  * **at**:number - searches messages with the given Application Terminated message id. [More about numbers](#Numbers.md)
  * **channel**:name - searches messages that are in the channel with the given name.
  * **severity**:text - searches messages with the given severity. Severity can be _info_, _warning_ or _error_.  You can also do things like <i>severity:>=warning</i>.
  * **before**:date - searches messages that happened after the given date. [More about dates](#Dates.md).
  * **after**:date - searches messages that happened after the given date. [More about dates](#Dates.md).

## Texts ##

When searching fields that are texts you can write any of these:

  * subject:something
  * subject:"something that has spaces on it"

The search is done without case taking into account, and it searches for inclusion of that text, not an exact match.

## Numbers ##

When searcing fields that are numbers you can write any of these:

  * tries:0 - tries must be zero
  * tries:<2 - tries is less than 2
  * tries:>2 - tries is greater than 2
  * tries:<=2 - tries is less than or equal to 2
  * tries:>=2 - tries is greater than or equal to 2

## Dates ##

When searching before or after a giving date you can supply natural language restrictions. Some examples:

  * before:"3 days ago"
  * after:"1 hour ago"