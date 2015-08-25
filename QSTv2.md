# Introduction #

See previous version here: http://code.google.com/p/geochat/wiki/QueueStateTransfer

This version of QST is simplified and enhanced at the same time to maximize throughput between endpoints.
There is now a single URL that is used both for pulling and pushing messages.

# Message Format #
The format of the messages can be XML or JSON.

## XML ##
When sending and receiving messages in XML format, the "text/xml" content type is used.

```
<messages>
  <message id="24c287Ba-9007-4280-99aa-66e0baa69f5a" from="sms://838383" to="twitter://foo" when="2010-01-01T23:18:83Z">
    <subject>asdfa</subject>
    <body>asfasdf</subject>
    <property name="custom-property" value="foo" />
    <property name="another-property" value="123" />
  </message>
</messages>
```

## JSON ##
When sending and receiving messages in JSON format, the "application/json" content type is used.

```
[
 { id: "24c287Ba-9007-4280-99aa-66e0baa69f5a",
   from: "sms://838383",
   to: "twitter://foo",
   when: "2010-01-01T23:18:83Z"
   subject: "Subject",
   body: "Body",
   custom-property: "foo",
   another-property: 123
 }
]
```

# Pushing messages #

```
POST /url
Content-Type: text/xml
Content-Length: ...

<messages>
  ...
</messages>
```

Pushing messages is now all or nothing. The server must return a HTTP status 200 (OK) if it successfully processed all the messages. Otherwise, depending on the status code, the client should retry the message (ie: 500 - Internal Server Error), discard it (ie: 400 - Bad Request) or stop sending messages at all (ie: 401 - Unauthorized).

# Pulling messages #

Pulling messages is performed using a GET request to the QST endpoint. The following optional attributes can be used in the query string:

  * **etag**: The last ETag returned by the server in a previous request. This confirms to the server that the messages were processed.
  * **long-polling**=_true_|_false_: When enabled, if the server doesn't have any message to return it holds the connection until a message arrives. Defaults to _false_.
  * **format**=_xml_|_json_: Specifies the desired format. Defaults to _xml_.