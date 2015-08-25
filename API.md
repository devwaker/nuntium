# Public API #



## Libraries ##

  * C#: [nuntium-api-csharp](http://nuntium-api-csharp.googlecode.com)
  * PHP: [nuntium-api-php](http://bitbucket.org/instedd/nuntium-api-php)
  * Ruby: [nuntium-api-ruby](http://nuntium-api-ruby.googlecode.com)

## Authentication ##

  * **none**: no authentication is required
  * **account**: HTTP Basic Auth with username "account\_name" and account's password
  * **application**: HTTP Basic Auth with username "account\_name/application\_name" and application's password
  * **account and application**: both account and application authentication are supported

## Carriers ##

### List all carriers ###

`HTTP GET /api/carriers.{xml|json}?country_id=CC(C)`

_Authentication: none_

List of carriers with their GUIDs for a given country. The country code can be the iso 2 or 3 letters. If no country code is given, all carriers are listed.

**Examples**

**Request:**

`HTTP GET /api/carriers.xml?country_code=ar`

**Response:**

`HTTP/1.1 200 OK`

```
<?xml version="1.0" encoding="UTF-8"?>
<carriers type="array">
  <carrier name="Personal" country_iso2="ar" guid="c09dc81a-2f0d-4332-9459-ab49e6690908"/>
</carriers>
```

**Request:**

`HTTP GET /api/carriers.json?country_code=ar`

**Response:**

`HTTP/1.1 200 OK`

```
[{"name":"Personal","guid":"c09dc81a-2f0d-4332-9459-ab49e6690908","country_iso2":"ar"}]
```

### Show a carrier ###

`HTTP GET /api/carriers/<guid>.{xml|json}`

_Authentication: none_

Show a carrier given its GUID. Responds with `HTTP_NOT_FOUND` if the carrier with the given GUID does not exist.

**Examples**

**Request:**

`HTTP GET /api/carriers/c09dc81a-2f0d-4332-9459-ab49e6690908.xml`

**Response:**

`HTTP/1.1 200 OK`

```
<?xml version="1.0" encoding="UTF-8"?>
<carrier name="Personal" country_iso2="ar" guid="c09dc81a-2f0d-4332-9459-ab49e6690908"/>
```

**Request:**

`HTTP GET /api/carriers/c09dc81a-2f0d-4332-9459-ab49e6690908.json`

**Response:**

`HTTP/1.1 200 OK`

```
{"name":"Personal","guid":"c09dc81a-2f0d-4332-9459-ab49e6690908","country_iso2":"ar"}
```

## Channels ##

### Channel specification ###

Every channel in nuntium must have the following properties:

  * **name**: must only contain alphanumeric characters, dash or underscore. Spaces are not allowed
  * **[kind](Channels#Kinds.md)**
  * **[protocol](Channels#Protocols.md)**
  * **[direction](Channels#Directions.md)**: incoming, outgoing or bidirectional
  * **address**: (optional) the address from which an incoming or bidirectional channel sends messages (informative)
  * **priority**: a number
  * **throttle**: (optional) number of messages to send per minute, or zero for non-throttled
  * **enabled**: (optional) true or false

Additionally each channel has configuration properties that are specific to each channel kind.

#### clickatell ####

  * **user**: (only for outgoing or bidirectional channels)
  * **password**: (only for outgoing or bidirectional channels)
  * **from**: (only for outgoing or bidirectional channels)
  * **api\_id**
  * **network**: (optional) 61, 44a, 46, 49, 45, 44b or usa
  * **concatenation**
  * **incoming\_password**: (only for incoming channels)

#### dtac ####

  * **user**
  * **password**
  * **sno**

#### pop3 ####

  * **host**
  * **port**
  * **user**
  * **password**
  * **use\_ssl**: true or false

#### qst\_client ####

  * **url**
  * **user**
  * **password**

#### qst\_server ####

  * **password**

#### smpp ####

  * **host**
  * **port**
  * **user**
  * **password**
  * **system\_type**: for example 'vma'
  * **source\_ton**
  * **source\_npi**
  * **destination\_ton**
  * **destination\_npi**
  * **endianess**: big or little
  * **accept\_mo\_hex\_string**: true or false
  * **default\_mo\_encoding**: ascii, latin1, ucs-2 or gsm
  * **mt\_encodings**: comma separated list of values that can be ascii, latin1 or ucs-2
  * **mt\_max\_length**
  * **mt\_csms\_method**: udh, optional\_parameters or message\_paylod

#### smtp ####

  * **host**
  * **port**
  * **user**
  * **password**
  * **use\_ssl**: true or false

#### twitter ####

  * **screen\_name**
  * **welcome\_message**: (optional) message to send to users subscribing to the user
  * **token**: obtained via OAUTH authentication
  * **secret**: obtained via OAUTH authentication

#### xmpp ####
  * **user**
  * **domain**
  * **password**
  * **server** (optional)
  * **port**
  * **resource** (optional)
  * **status**: (optional) the status to show in the contact list when connecting

### List all channels ###

`HTTP GET /api/channels.{xml|json}`

_Authentication: account, application_

List both channels that belong to an application and that does not belong to any application.

**Examples**

**Request:**

`HTTP GET /api/channels.xml`

**Response:**

`HTTP/1.1 200 OK`

```
<?xml version="1.0" encoding="UTF-8"?>
<channels> 
  <channel kind="clickatell" direction="outgoing" enabled="true" name="foo" protocol="sms" priority="100" address="sms://1234"> 
    <configuration>
      <property value="1" name="api_id"/> 
      <property value="c" name="from"/> 
      <property value="45" name="network"/> 
      <property value="a" name="user"/> 
      <property value="3" name="concat"/> 
    </configuration>
    <restrictions>
      <property value="bar" name="foo"/> 
      <property value="baz" name="foo"/> 
      <property value="prop" name="another"/> 
    </restrictions>
  </channel> 
</channels>
```

**Request:**

`HTTP GET /api/channels.json`

**Response:**

`HTTP/1.1 200 OK`

```
[{
  "kind": "clickatell",
  "direction": "outgoing",
  "enabled": "true",
  "configuration":[
    {"value": "1", "name": "api_id"},
    {"value": "c", "name": "from"},
    {"value": "45", "name": "network"},
    {"value": "a", "name": "user"},
    {"value": "3", "name": "concat"}
  ],
  "restrictions":[
    {"value": ["bar", "baz"], "name": "foo"},
    {"value": "prop", "name": "another"}
  ]
  "name":"foo",
  "protocol":"sms",
  "priority":100,
  "address":"sms://1234"
}]
```

### Create a channel ###

`HTTP POST /api/channels.{xml|json}`

_Authentication: account, application_

Creates a channel that will belong to an application.

Responds with `HTTP_BAD_REQUEST` if the some of the channel's fields are not valid. Check the [errors section](API#Channel_errors.md) for more info.

**Examples**

**Request:**

`HTTP POST /api/channels.xml`

```
<?xml version="1.0" encoding="UTF-8"?>
<channel kind="clickatell" direction="outgoing" enabled="true" name="foo" protocol="sms" priority="100" address="sms://1234"> 
  <configuration>
    <property value="1" name="api_id"/> 
    <property value="c" name="from"/> 
    <property value="45" name="network"/> 
    <property value="a" name="user"/> 
    <property value="3" name="concat"/> 
  </configuration>
  <restrictions>
    <property value="bar" name="foo"/> 
    <property value="baz" name="foo"/> 
    <property value="prop" name="another"/> 
  </restrictions>
</channel>
```

**Response:**

`HTTP/1.1 200 OK`

**Request:**

`HTTP POST /api/channels.json`

```
{
  "kind": "clickatell",
  "direction": "outgoing",
  "enabled": "true",
  "configuration":[
    {"value": "1", "name": "api_id"},
    {"value": "c", "name": "from"},
    {"value": "45", "name": "network"},
    {"value": "a", "name": "user"},
    {"value": "3", "name": "concat"}
  ],
  "restrictions":[
    {"value": ["bar", "baz"], "name": "foo"},
    {"value": "prop", "name": "another"}
  ]
  "name":"foo",
  "protocol":"sms",
  "priority":100,
  "address":"sms://1234"
}
```

**Response:**

`HTTP/1.1 200 OK`

### Update a channel ###

`HTTP POST /api/channels.{xml|json}`

_Authentication: account, application_

Updates a channel that belongs to an application.

Only the attributes present in the given xml/json will be updated: the others will remain untouched. If a configuration element is present, all of the configuration values will be updated. The same is true for the restrictions element.

Responds with `HTTP_NOT_FOUND` if the channel does not exist.

Responds with `HTTP_FORBIDDEN` if the channel belongs to another application (when authenticated as an application).

Responds with `HTTP_BAD_REQUEST` if some of the channel's fields are not valid. Check the [errors section](API#Channel_errors.md) for more info.

**Examples**

**Request:**

`HTTP PUT /api/channels/foo.xml`

```
<?xml version="1.0" encoding="UTF-8"?>
<channel kind="clickatell" direction="outgoing" enabled="true" name="foo" protocol="sms" priority="100" address="sms://1234"> 
  <configuration>
    <property value="1" name="api_id"/> 
    <property value="c" name="from"/> 
    <property value="45" name="network"/> 
    <property value="a" name="user"/> 
    <property value="3" name="concat"/> 
  </configuration>
  <restrictions>
    <property value="bar" name="foo"/> 
    <property value="baz" name="foo"/> 
    <property value="prop" name="another"/> 
  </restrictions>
</channel>
```

**Response:**

`HTTP/1.1 200 OK`

**Request:**

`HTTP PUT /api/channels/foo.json`

```
{
  "kind": "clickatell",
  "direction": "outgoing",
  "enabled": "true",
  "configuration":[
    {"value": "1", "name": "api_id"},
    {"value": "c", "name": "from"},
    {"value": "45", "name": "network"},
    {"value": "a", "name": "user"},
    {"value": "3", "name": "concat"}
  ],
  "restrictions":[
    {"value": ["bar", "baz"], "name": "foo"},
    {"value": "prop", "name": "another"}
  ]
  "protocol":"sms",
  "priority":100,
  "address":"sms://1234"
}
```

**Response:**

`HTTP/1.1 200 OK`

### Show a channel ###

`HTTP GET /api/channels/<channel_name>.{xml|json}`

_Authentication: account, application_

Show the channel that belong to an application or that does not belong to any application.

Responds with `HTTP_NOT_FOUND` if the channel does not exist.

**Examples**

**Request:**

`HTTP GET /api/channels/foo.xml`

**Response:**

`HTTP/1.1 200 OK`

```
<?xml version="1.0" encoding="UTF-8"?>
<channel kind="clickatell" direction="outgoing" enabled="true" name="foo" protocol="sms" priority="100" address="sms://1234"> 
  <configuration>
    <property value="1" name="api_id"/> 
    <property value="c" name="from"/> 
    <property value="45" name="network"/> 
    <property value="a" name="user"/> 
    <property value="3" name="concat"/> 
  </configuration>
  <restrictions>
    <property value="bar" name="foo"/> 
    <property value="baz" name="foo"/> 
    <property value="prop" name="another"/> 
  </restrictions>
</channel>
```

**Request:**

`HTTP GET /api/channels/foo.json`

**Response:**

`HTTP/1.1 200 OK`

```
{
  "kind": "clickatell",
  "direction": "outgoing",
  "enabled": "true",
  "configuration":[
    {"value": "1", "name": "api_id"},
    {"value": "c", "name": "from"},
    {"value": "45", "name": "network"},
    {"value": "a", "name": "user"},
    {"value": "3", "name": "concat"}
  ],
  "restrictions":[
    {"value": ["bar", "baz"], "name": "foo"},
    {"value": "prop", "name": "another"}
  ]
  "name":"foo",
  "protocol":"sms",
  "priority":100,
  "address":"sms://1234"
}
```

### Delete a channel ###

`HTTP DELETE /api/channels/<channel_name>`

_Authentication: account, application_

Deletes a channel that belong to an application.

Responds with `HTTP_NOT_FOUND` if the channel does not exist.

Responds with `HTTP_FORBIDDEN` if the channel belongs to another application (when authenticated as an application).

**Examples**

**Request:**

`HTTP DELETE /api/channels/foo`

**Response:**

`HTTP/1.1 200 OK`

### Candidate channels ###

`HTTP GET /api/candidate/channels.{xml|json}?from=...&to=...&subject=...&body=...`

_Authentication: application_

List candidate channels that will be used when routing the given AO Message, that is, the result of the [Channel Filter Phase](Channels#Channel_Filter_Phase.md). This does not perform the routing, it just simulates it and returns the candidate channels list.

**Examples**

**Request:**

`HTTP GET /api/candidate/channels.xml?from=sms://1&to=sms://2&subject=Hello&body=Hi`

**Response:**

`HTTP/1.1 200 OK`

```
<?xml version="1.0" encoding="UTF-8"?>
<channels> 
  <channel kind="clickatell" direction="outgoing" enabled="true" name="foo" protocol="sms" priority="100" address="sms://1234"> 
    <configuration>
      <property value="1" name="api_id"/> 
      <property value="c" name="from"/> 
      <property value="45" name="network"/> 
      <property value="a" name="user"/> 
      <property value="3" name="concat"/> 
    </configuration>
    <restrictions>
      <property value="bar" name="foo"/> 
      <property value="baz" name="foo"/> 
      <property value="prop" name="another"/> 
    </restrictions>
  </channel> 
</channels>
```

**Request:**

`HTTP GET /api/candidate/channels.json?from=sms://1&to=sms://2&subject=Hello&body=Hi`

**Response:**

`HTTP/1.1 200 OK`

```
[{
  "kind": "clickatell",
  "direction": "outgoing",
  "enabled": "true",
  "configuration":[
    {"value": "1", "name": "api_id"},
    {"value": "c", "name": "from"},
    {"value": "45", "name": "network"},
    {"value": "a", "name": "user"},
    {"value": "3", "name": "concat"}
  ],
  "restrictions":[
    {"value": ["bar", "baz"], "name": "foo"},
    {"value": "prop", "name": "another"}
  ]
  "name":"foo",
  "protocol":"sms",
  "priority":100,
  "address":"sms://1234"
}]
```

### Specific channel APIs ###

Some channel kinds support additional API methods.

#### Twitter ####

##### Create friendship #####

`HTTP GET /api/channels/<name>/twitter/friendships/create?user=<user>&follow=<follow>`

_Authentication: account, application_

Creates a friendship between the channel's twitter account and the given user.

Returns `HTTP_OK` if the friendship could be created or if the frienship already existed.

Refer to Twitter's documentation: http://apiwiki.twitter.com/Twitter-REST-API-Method:-friendships%C2%A0create

Responds with `HTTP_NOT_FOUND` if the channel does not exist.

Responds with `HTTP_FORBIDDEN` if the channel belongs to another application (when authenticated as an application).

Responds with `HTTP_BAD_REQUEST` if the channel is not a Twitter channel.

### Channel errors ###

When creating or updating a channel, if some of the fields are missing or are invalid, an `HTTP_BAD_REQUEST` response is returned. The body of the response contains the error messages.

**Examples**

**Request:**

`HTTP POST /api/channels.xml`

```
<?xml version="1.0" encoding="UTF-8"?>
<channel kind="clickatell" direction="outgoing" enabled="true" name="foo" priority="100"> 
  <configuration>
    <property value="1" name="api_id"/> 
    <property value="c" name="from"/> 
    <property value="45" name="network"/> 
    <property value="a" name="user"/> 
    <property value="3" name="concat"/> 
  </configuration>
  <restrictions>
    <property value="bar" name="foo"/> 
    <property value="baz" name="foo"/> 
    <property value="prop" name="another"/> 
  </restrictions>
</channel>
```

**Response:**

`HTTP/1.1 400 BAD REQUEST`

```
<?xml version="1.0" encoding="UTF-8"?>
<error summary="There were some problems">
  <property name="protocol" value="can't be blank" />
</error>
```

**Request:**

`HTTP POST /api/channels.json`

**Response:**

`HTTP/1.1 400 BAD REQUEST`

```
{
  "summary": "There were some problems",
  "properties" => {
    "protocol" => "can't be blank"
  }
}
```

## Countries ##

### List all countries ###

`HTTP GET /api/countries.{xml|json}`

_Authentication: none_

List of countries with their phone prefixes known for Nuntium.

**Examples**

**Request:**

`HTTP GET /api/countries.xml`

**Response:**

`HTTP/1.1 200 OK`

```
<?xml version="1.0" encoding="UTF-8"?>
<countries>
  <country name="Argentina" iso2="ar" iso3="arg" phone_prefix="54" />
</countries>
```

**Request:**

`HTTP GET /api/countries.json`

**Response:**

`HTTP/1.1 200 OK`

```
[{
  "name": "Argentina",
  "iso2": "ar",
  "phone_prefix": "54",
  "iso3": "arg"
}]
```

### Show a country ###

`HTTP GET /api/countries/<iso2_or_iso3>.{xml|json}`

_Authentication: none_

Shows a country given its iso2 or iso3 code. Responds with `HTTP_BAD_REQUEST` if no country exists with that iso code.

**Examples**

**Request:**

`HTTP GET /api/countries/ar.xml`

**Response:**

`HTTP/1.1 200 OK`

```
<?xml version="1.0" encoding="UTF-8"?>
<country name="Argentina" iso2="ar" iso3="arg" phone_prefix="54" />
```

**Request:**

`HTTP GET /api/countries/ar.json`

**Response:**

`HTTP/1.1 200 OK`

```
{
  "name": "Argentina",
  "iso2": "ar",
  "phone_prefix": "54",
  "iso3": "arg"
}
```

## Messages ##

### Send an Application Originated message ###

```
HTTP GET /<account_name>/<application_name>/send_ao.{xml|json}
HTTP POST /<account_name>/<application_name>/send_ao.{xml|json}
```

_Authentication: application_

Sends one or more Application Originated messages.

If no format is specified (the request is made as just send\_ao) one message will be sent and the request should include form data. The form data can contain the following fields: from, to, subject, body, guid, timestamp, token. Additional form data will be set as custom attributes, with the exception of the following fields: controller, action, application\_name, account\_name.

If the JSON format is specified (send\_ao.json) the POST body must be an array of hashes.

If the XML format is specified (send\_ao.xml) the POST body must be as specified in the [QST protocol](http://code.google.com/p/geochat/wiki/QueueStateTransfer).

Responds with `HTTP_OK`. In any case, the following custom HTTP headers will be sent in the response:

  * X-Nuntium-Id: (when no format is specified) the id of the message kept by Nuntium.
  * X-Nuntium-Guid: the guid of the message. This is the one that was sent in the request, or a randomly generated one if none was specified.
  * X-Nuntium-Token: a token to be able to retrieve messages sent in this request. See [Get Application Originated Messages](API#Get_Application_Originated_messages.md) and [Tokens](Tokens.md). This will be automatically generated if not specified in the request.

**Examples**

**Request:**

`HTTP GET /account_name/application_name/send_ao?from=sms://0&to=sms://1&subject=Hello`

**Response:**

```
HTTP/1.1 200 OK
X-Nuntium-Id: 1343
X-Nuntium-Guid: 2b483424-2c2a-4702-b391-651f2a21da9d
X-Nuntium-Token: 8212275-c104-1bbd-4a22-a94943fa263d2
```

### Get Application Originated messages ###

```
HTTP GET /<account_name>/<application_name>/get_ao.json?token={token}
```

_Authentication: application_

Gets Application Originated messages with the given [token](Tokens.md).

Returns a JSON, an array of hashes with the properties of the message: from, to, subject, body, guid, state, channel (the channel's name), channel\_kind and custom atrributes.

Responds with `HTTP\_OK.