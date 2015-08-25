# Introduction #

The intention is to simplify the setup of a local gateway. LGW will show a 4-digit code. The code will be entered in the end-user application. The application will create a channel providing the `ticket_code`, and finally the localgateway will receive the channel credential information that bind it to the application.

The first step is for the localgateway to request a ticket

**Request**
`HTTP POST /tickets.json'

```
address=ADDRESS
```

**Response**

```
{ 
  'code' : 'CODE', 
  'secret_key' : 'SECRET-GUID-VALUE', 
  'status' : 'pending',
  'data' : {
    'address' : 'ADDRESS'
  }
}
```

The localgateway need to continuously request the status of the ticket. As long as no  channel is created with the `ticket_code`, the following request will succeed as follows:

**Request**

`HTTP GET /tickets/CODE.json?secret_key=SECRET-GUID-VALUE`

**Response**

```
{ 
  'code' : 'CODE', 
  'secret_key' : 'SECRET-GUID-VALUE', 
  'status' : 'pending',
  'data' : {
    'address' : 'ADDRESS'
  }
}
```

As soon as a channel is created, the same request will succeed as follows:

**Request**

`HTTP GET /tickets/CODE.json?secret_key=SECRET-GUID-VALUE`

**Response**

```
{ 
  'code' : 'CODE', 
  'secret_key' : 'SECRET-GUID-VALUE', 
  'status' : 'complete',
  'data' : {
    'address' : 'ADDRESS',
    'account' : 'NUNTIUM-ACCOUNT-NAME',
    'channel' : 'NUNTIUM-CHANNEL-NAME',
    'password' : 'NUNTIUM-CHANNEL-PASSWORD',
    'message' : 'APP-SUCCESS-CHANNEL-CREATION'
  }
}
```

In order to create and channel with the code, use the same api method, and specify values for `ticket_code` and `ticket_message`.