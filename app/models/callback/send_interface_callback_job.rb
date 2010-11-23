class SendInterfaceCallbackJob
  attr_accessor :account_id, :application_id, :message_id

  def initialize(account_id, application_id, message_id)
    @account_id = account_id
    @application_id = application_id
    @message_id = message_id
  end

  def perform
    account = Account.find_by_id @account_id
    app = account.find_application @application_id
    msg = ATMessage.get_message @message_id
    return true if msg.state != 'queued'

    content_type = "application/x-www-form-urlencoded"

    if app.interface_custom_format.present?
      looks_like_xml = looks_like_xml?(app.interface_custom_format)
      if app.interface == 'http_post_callback' && looks_like_xml
        content_type = 'application/xml'
      end
      data = apply_custom_format msg, app, looks_like_xml
    else
      data = {
        :application => app.name,
        :from => msg.from,
        :to => msg.to,
        :subject => msg.subject,
        :body => msg.body,
        :guid => msg.guid,
        :channel => msg.channel.name
      }.merge(msg.custom_attributes)
      data = data.to_query if app.interface == 'http_get_callback'
    end

    options = {:headers => {:content_type => content_type}}
    if app.interface_user.present?
      options[:user] = app.interface_user
      options[:password] = app.interface_password
    end

    begin
      res = RestClient::Resource.new(app.interface_url, options)
      res = app.interface == 'http_get_callback' ? res["?#{data}"].get : res.post(data)
      netres = res.net_http_res

      case netres
        when Net::HTTPSuccess, Net::HTTPRedirection
          ATMessage.update_tries([msg.id],'delivered')
          ATMessage.log_delivery([msg], account, 'http_post_callback')

          # If the response includes a body, create an AO message from it
          if res.body.present?
            reply = AOMessage.new :from => msg.to, :to => msg.from, :body => res.body
            app.route_ao reply, 'http post callback'
          end

          return true
        when Net::HTTPUnauthorized
          app.alert "Sending HTTP POST callback received unauthorized: invalid credentials"

          app.interface = 'rss'
          app.save!
          return false
        else
          alert_msg = "HTTP POST callback failed #{netres.error!}"
          app.alert alert_msg

          ATMessage.update_tries([msg.id],'failed')
          #TODO check if this error is logged
          account.logger.error :at_message_id => @message_id, :message => alert_msg
          raise netres.error!
      end
    rescue RestClient::BadRequest
      msg.send_failed account, app, "Received HTTP Bad Request (404)"
      return true
    end
  end

  def to_s
    "<SendInterfaceCallbackMessageJob:#{@message_id}>"
  end

  private

  def apply_custom_format(msg, app, looks_like_xml)
    escape = app.interface == 'http_get_callback'
    app.interface_custom_format.gsub(%r(\$\{(.*?)\})) do |match|
      # Remove the ${ from the beginning and the } from the end
      match = match[2 .. -2]
      if MessageCommon::Fields.include? match
        match = msg.send match
      elsif match == 'from_without_protocol'
        match = msg.from.try(:without_protocol)
      elsif match == 'to_without_protocol'
        match = msg.to.try(:without_protocol)
      elsif match == 'subject_and_body'
        match = msg.subject_and_body
      elsif match == 'channel'
        match = msg.channel.name
      elsif match == 'application'
        match = app.name
      else
        match = msg.custom_attributes[match]
      end
      match ||= ''
      if looks_like_xml
        match = match.to_xs
      elsif escape
        match = CGI.escape(match || '')
      end
      match
    end
  end

  def looks_like_xml?(string)
    string =~ %r(</(.*?)>) && %r(<#{$1})
  end
end