# Tokens #

Tokens allow you to retrieve Application Originated messages from Nuntium.

A typical workflow of an application might be:
  * A user sends an Application Terminated message.
  * Nuntium delivers that message to the application via the HTTP interface.
  * The application responds with an XML or JSON containing the Application Originated messages in reply to the incoming message.
  * Nuntium delivers the Application Originated messages to the users.

In this case it might be helpful, from the application side, to know what happened with those AO messages: where they correctly delivered? What are all the generated messages from that single AT message?

You can retrieve those messages via an [API call](API#Get_Application_Originated_messages.md) passing along a token.

In case an HTTP request was used to deliver the AT message, the guid is used as the token for the AO messages contained in the response body, unless overriten in the XML or JSON response.

In case  you send AO messages via an [API call](API#Send_an_Application_Originated_message.md), a header containing the token will be returned, unless overritten in the request body.