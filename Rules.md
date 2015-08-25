# Routing Rules #

You can specify routing rules in many points of the [AO](AOMessageRouting.md) and [AT](ATMessageRouting.md) routing algorithms.

Each rule is made of conditions and actions.

## Conditions ##

Conditions specify when a rule's actions are executed.

  * When no condition is specified, the rule's actions are always executed.
  * When more than one condition is specified, the rule's actions will be executed when all the conditions are true.

For conditions on text fields, such as "from", "to", "subject" and "body", you can specify simple operations like "is" (test for equality), "is not", and "starts with". More complex conditions on these fields can be specified using regular expressions.

### Regular Expressions ###

Their syntax used must be that of [Ruby](http://www.regular-expressions.info/ruby.html). When using groups matching you can use them in the actions:

  * **${n}**, where _n_ is an integer equal to or bigger than 1, will match the nth group of the first condition that tests for a regular expression.
  * **${field.n}**, where _field_ is the name of a field such as "from", "to", "subject" and "body", and _n_ is an integer equal to or bigger than 1, will match the nth group of the condition on that field.

## Actions ##

Actions set or change a [message's fields](Messages#Structure_of_a_message.md) or [custom attributes](Messages#Custom_attributes.md).