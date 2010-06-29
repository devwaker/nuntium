class ApiAuthenticatedController < ApplicationController

  before_filter :authenticate

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      success = false
      account_name, app_name = username.split('/')
      if account_name and app_name
        @account = Account.find_by_id_or_name account_name
        if @account
          @application = @account.find_application app_name
          if @application and @application.authenticate password
            @application.account = @account
            success = true
          end
        end
      end
      success
    end
  end
  
end
