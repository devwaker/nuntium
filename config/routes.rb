ActionController::Routing::Routes.draw do |map|
  # Home
  map.root :controller => 'home'
  [:interactions, :settings, :applications, :channels, :ao_messages, :at_messages, :logs, :visualizations].each do |name|
    map.send(name, "/#{name}", :controller => 'home', :action => name)
  end

  # Interfaces
  map.resources :rss, :path_prefix => '/:account_name/:application_name', :only => [:index, :create]
  map.send_ao '/:account_name/:application_name/send_ao', :controller => 'send_ao', :action => :create

  # Qst
  map.resources :incoming, :path_prefix => '/:account_id/qst', :only => [:index, :create]
  map.resources :outgoing, :path_prefix => '/:account_id/qst', :only => [:index]
  map.qst_set_address '/:account_id/qst/setaddress', :controller => 'address', :action => :update

  # Clickatell
  map.clickatel_credit '/clickatell/view_credit', :controller => 'clickatell', :action => :view_credit
  map.clickatel '/:account_id/clickatell/incoming', :controller => 'clickatell', :action => :index
  map.clickatel_ack '/:account_id/clickatell/ack', :controller => 'clickatell', :action => :ack

  # Dtac
  map.dtac '/:account_id/dtac/incoming', :controller => 'dtac', :action => :index

  # Accounts
  map.create_account '/create_account', :controller => 'home', :action => :create_account
  map.login '/login', :controller => 'home', :action => :login
  map.logoff '/logoff', :controller => 'home', :action => :logoff
  map.update_account '/account/update', :controller => 'home', :action => :update_account
  map.update_application_routing_rules '/account/update_application_routing_rules', :controller => 'home', :action => :update_application_routing_rules

  # Twitter mappings must come before generic channel mapping
  map.create_twitter_channel '/channel/create/twitter', :controller => 'twitter', :action => :create_twitter_channel, :kind => 'twitter'
  map.update_twitter_channel '/channel/update/twitter/:id', :controller => 'twitter', :action => :update_twitter_channel
  map.twitter_callback '/twitter_callback', :controller => 'twitter', :action => :twitter_callback
  map.twitter_rate_limit_status '/twitter/view_rate_limit_status', :controller => 'twitter', :action => :view_rate_limit_status

  # Channels
  map.new_channel '/channel/new/:kind', :controller => 'channel', :action => :new_channel
  map.create_channel '/channel/create/:kind', :controller => 'channel', :action => :create_channel
  map.edit_channel '/channel/edit/:id', :controller => 'channel', :action => :edit_channel
  map.update_channel '/channel/update/:id', :controller => 'channel', :action => :update_channel
  map.delete_channel '/channel/delete/:id', :controller => 'channel', :action => :delete_channel
  map.enable_channel '/channel/enable/:id', :controller => 'channel', :action => :enable_channel
  map.disable_channel '/channel/disable/:id', :controller => 'channel', :action => :disable_channel
  map.pause_channel '/channel/pause/:id', :controller => 'channel', :action => :pause_channel
  map.unpause_channel '/channel/resume/:id', :controller => 'channel', :action => :resume_channel

  # Applications
  map.new_application '/application/new', :controller => 'home', :action => :new_application
  map.create_application '/application/create', :controller => 'home', :action => :create_application
  map.edit_application '/application/edit/:id', :controller => 'home', :action => :edit_application
  map.update_application '/application/update/:id', :controller => 'home', :action => :update_application
  map.delete_application '/application/delete/:id', :controller => 'home', :action => :delete_application

  # Messages
  map.view_thread '/message/thread', :controller => 'message', :action => :view_thread

  # AO messages
  map.new_ao_message '/message/ao/new', :controller => 'message', :action => :new_ao_message
  map.create_ao_message '/message/ao/create', :controller => 'message', :action => :create_ao_message
  map.mark_ao_messages_as_cancelled '/message/ao/mark_as_cancelled', :controller => 'message', :action => :mark_ao_messages_as_cancelled
  map.mark_ao_messages_as_cancelled '/message/ao/reroute', :controller => 'message', :action => :reroute_ao_messages
  map.candidate_channels '/message/ao/candidate_channels', :controller => 'message', :action => :candidate_channels
  map.simulate_route_ao '/message/ao/simulate_route', :controller => 'message', :action => :simulate_route_ao
  map.simulate_route_at '/message/at/simulate_route', :controller => 'message', :action => :simulate_route_at
  map.view_ao_message '/message/ao/:id', :controller => 'message', :action => :view_ao_message
  map.ao_rgviz '/messages/ao/rgviz', :controller => 'message', :action => :ao_rgviz

  # AT messages
  map.new_at_message '/message/at/new', :controller => 'message', :action => :new_at_message
  map.create_at_message '/message/at/create', :controller => 'message', :action => :create_at_message
  map.mark_at_messages_as_cancelled '/message/at/mark_as_cancelled', :controller => 'message', :action => :mark_at_messages_as_cancelled
  map.view_at_message '/message/at/:id', :controller => 'message', :action => :view_at_message
  map.at_rgviz '/messages/at/rgviz', :controller => 'message', :action => :at_rgviz

  # Visualization
  map.visualization_ao_state_by_day '/visualization/ao/state_by_day', :controller => 'visualization', :action => :ao_state_by_day
  map.visualization_at_state_by_day '/visualization/at/state_by_day', :controller => 'visualization', :action => :at_state_by_day

  # API
  map.countries '/api/countries.:format', :controller => 'api_country', :action => :index
  map.country '/api/countries/:iso.:format', :controller => 'api_country', :action => :show
  map.carriers '/api/carriers.:format', :controller => 'api_carrier', :action => :index
  map.carrier '/api/carriers/:guid.:format', :controller => 'api_carrier', :action => :show
  map.api_channels_index '/api/channels.:format', :conditions => {:method => :get}, :controller => 'api_channel', :action => :index
  map.api_channels_create '/api/channels.:format', :conditions => {:method => :post}, :controller => 'api_channel', :action => :create
  map.api_channels_show '/api/channels/:name.:format', :conditions => {:method => :get}, :controller => 'api_channel', :action => :show
  map.api_channels_update '/api/channels/:name.:format', :conditions => {:method => :put}, :controller => 'api_channel', :action => :update
  map.api_channels_destroy '/api/channels/:name', :conditions => {:method => :delete}, :controller => 'api_channel', :action => :destroy
  map.api_candidate_channels '/api/candidate/channels.:format', :conditions => {:method => :get}, :controller => 'api_channel', :action => :candidates
  map.api_twitter_follow '/api/channels/:name/twitter/friendships/create', :conditions => {:method => :get}, :controller => 'api_twitter_channel', :action => :friendship_create

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
