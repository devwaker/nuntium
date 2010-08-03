class ApiChannelController < ApiAuthenticatedController

  # GET /api/channels.:format
  def index
    channels = @account.channels
    channels = channels.select{|c| c.application_id.nil? || c.application_id == @application.id}
    channels.each do |c| 
      c.account = @account
      c.application = @application if c.application_id
    end
    
    respond channels
  end
  
  # GET /api/channels/:name.:format
  def show
    channels = @account.channels
    channels = channels.select{|c| c.application_id.nil? || c.application_id == @application.id}
    channel = channels.select{|x| x.name == params[:name]}.first
    
    return head :not_found unless channel
    
    respond channel
  end
  
  # POST /api/channels.:format
  def create
    data = request.POST.present? ? request.POST : request.raw_post
    chan = nil
    respond_to do |format|
      format.xml { chan = Channel.from_xml(data) }
      format.json { chan = Channel.from_json(data) } 
    end
    chan.account = @account
    if @application
      chan.application = @application
    else
      app_name = data[:application] || (data[:channel] && data[:channel][:application])
      if app_name
        chan.application = @account.find_application app_name
      end
    end
    save chan, 'creating'
  end
  
  # PUT /api/channels/:name.:format
  def update
    chan = @account.find_channel params[:name]
    return head :bad_request unless chan and (@application.nil? || chan.application_id == @application.id)
  
    data = request.POST.present? ? request.POST : request.raw_post
    update = nil
    respond_to do |format|
      format.xml { update = Channel.from_xml(data) }
      format.json { update = Channel.from_json(data) } 
    end
    chan.merge(update)
    
    new_app_name = data[:application] || (data[:channel] && data[:channel][:application])
    if new_app_name
      chan.application = @account.find_application new_app_name
    end
    save chan, 'updating'
  end
  
  # DELETE /api/channels/:name
  def destroy
    chan = @account.find_channel params[:name]
    if chan and (@application.nil? || chan.application_id == @application.id)
      chan.destroy
      head :ok
    else
      head :bad_request
    end
  end
  
  # GET /api/candidate/channels.:format
  def candidates
    msg = AOMessage.from_hash params
    msg.account_id = @account.id
    
    channels = @application.candidate_channels_for_ao msg
    respond channels
  end
  
  private
  
  def respond(object)
    respond_to do |format|
      format.xml { render :xml => object.to_xml(:root => 'channels', :skip_types => true) }
      format.json { render :json => object.to_json }
    end
  end
  
  def save(channel, action)
    if channel.save
      head :ok
    else
      respond_to do |format|
        format.xml { render :xml => errors_to_xml(channel.errors, action), :status => :bad_request }
        format.json { render :json => errors_to_json(channel.errors, action), :status => :bad_request } 
      end 
    end
  end
  
  def errors_to_xml(errors, action)
    require 'builder'
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.error :summary => "There were problems #{action} the channel" do
      errors.each do |name, value|
        xml.property :name => name, :value => value
      end
    end
    xml.target!
  end
  
  def errors_to_json(errors, action)
    attrs = {
      :summary => "There were problems #{action} the channel",
      :properties => []
    }
    errors.each do |name, value|
      attrs[:properties] << { name => value }
    end
    attrs.to_json
  end

end
