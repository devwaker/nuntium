class SendAoController < ApplicationAuthenticatedController

  # GET /:account_name/:application_name/send_ao.:format
  def create
    case params[:format]
    when nil
      create_single
    when 'json'
      create_many_json
    when 'xml'
      create_many_xml
    end
  end

  private

  def create_single
    msg = AOMessage.from_hash params
    route msg

    response.headers['X-Nuntium-Id'] = msg.id.to_s
    response.headers['X-Nuntium-Guid'] = msg.guid.to_s
    head msg.state == 'failed' ? :bad_request : :ok
  end

  def create_many_json
    AOMessage.from_json(request.raw_post) { |msg| route msg }
    head :ok
  end

  def create_many_xml
    AOMessage.parse_xml(request.raw_post) { |msg| route msg }
    head :ok
  end

  def route(msg)
    msg.account_id = @account.id
    @application.route_ao msg, 'http'
  end

end
