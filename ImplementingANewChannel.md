

# Implementing a new channel (developers) #

Nuntium have some well-known channels, like twitter, email, smpp and xmpp, but it might not have what you need. In that case, you will need to [get nuntium's code](http://code.google.com/p/nuntium/source/checkout), [install it locally](Installing.md) and add support for a new channel kind. If you develop a new channel kind, [let us know!](http://tech.groups.yahoo.com/group/nuntiumusers/)

Nuntium's philosophy is to have very specific channels that work very well, not generic channels that work more or less well and need a lot of configuration and tweaking. For that reason you will never see an HTTP channel.

## Implement the channel ##

A Channel is in charge of routing a message to the world. It can also tell nuntium to run a service that will poll messages from time to time, keep a connection alive to download messages, etc.

Create a new ruby file named "app/models/{**kind**}/{**camelized(kind)**}Channel.rb". So for example if your **kind** is "my\_kind", you would name the file "app/models/my\_kind/MyKindChannel.rb".

The new channel must extend Channel.

```
class MyKindChannel < Channel
end
```

How to implement this class depends on your channel needs.

### Generic outgoing channel ###

Include the `GenericChannel` module if:
  * Your channel will only be outgoing, that is, will only send messages from your application to the world, or
  * Your channel will be biderctional and you will also receive incoming messages via an HTTP callback

Specific configuration of the channel can be specified using the `configuration_accessor`.

```
class MyKindChannel < Channel
  include GenericChannel

  configuration_accessor :url

  validates_presence_of :url

  def self.title
    # By default it will be, in this case, "My Kind"
    "Some fancy title"
  end

  def check_valid_in_ui
    # This validation will be run when creating the channel via the
    # UI, not in tests. So here you can do more aggressive validations,
    # like check that a URL is responding requests
  end

  def info
    url
  end

end
```

As allways, check other channel implementations to understand this better.

#### Implement the send message job class ####

Define an "app/models/**kind**/send`_`**kind**`_`_message\_job.rb" file like this:_

```
class SendMyKindMessageJob < SendMessageJob
  def managed_perform
    # Here you have:
    # @msg: the AO message to be sent. Most notably, you will use
    #       the from, to, subject and body accessors. You also have
    #       the subject_and_body accessor that combines both subject
    #       and body with a dash.
    # @account
    # @channel
    # @config: convenience variable that holds the channel's configuration

    # Do whatever you want with the message...
    # For example, issue an HTTP get with it:
    data = { 
      :from => @msg.from,
      :to => @msg.to, 
      :text => @msg.subject_and_body
    }
    res = RestClient::Resource.new(@channel.url).post data
    netres = res.net_http_res
    case netres
    when Net::HTTPSuccess, Net::HTTPRedirection
      # Message was sent, must return "true"
      return true
    when Net::HTTPUnauthorized
      # Message was not sent, but it's a channel's problem.
      # Must raise a PermanentException
      raise PermamentException.new(Exception.new "unauthorized")
    else
      # Something else went wrong, probably something's wrong with
      # the message or a temporary error...
      # Must raise an Exception
      raise Exception.new("Something's wrong...")
    end
  end
end
```

And that's it! You have a new working outgoing channel.

For an example of a working outgoing channel check out the SMTP channel's source code:

http://code.google.com/p/nuntium/source/browse/#hg/app/models/smtp%3Fstate%3Dclosed

### Callback channel ###

If you need to receive incoming messages via an HTTP callback you will need to define a controller for that. Check for example the Clickatell controller:

http://code.google.com/p/nuntium/source/browse/app/controllers/clickatell_controller.rb

This implementation also takes into account delivery ACK callbacks.

### Polling channel ###

If you need to poll a URL or some other thing from time to time to receive AT messages via your chnanel you will need to define cron tasks to be executed. Check out the source code of the POP3 channel (you can also make it include GenericChannel to handle outgoing communication):

http://code.google.com/p/nuntium/source/browse/#hg/app/models/pop3

You basically need to include the CronChannel module and define the create\_tasks and destroy\_tasks methods.

### Service channel ###

If you need to establish a permanent connection to a service and, using that connection, send and receive messages, check out the source code for the XMPP channel.

The channel and a job to send a message that will work in a different way than the jobs described before:

http://code.google.com/p/nuntium/source/browse/#hg/app/models/xmpp

The service that will keep a connection to an XMPP server:

http://code.google.com/p/nuntium/source/browse/app/services/xmpp_service.rb

## Implement the UI for creating/editing the channel ##

Add a new html.erb template named "app/views/channels/`_`form_{**kind**}.html.erb"._

You can base yourself in another template for creating a channel, like this one:

http://code.google.com/p/nuntium/source/browse/app/views/channels/_form_qst_server.html.erb

# More help #

Please send a message to our [mailing list](http://tech.groups.yahoo.com/group/nuntiumusers/).