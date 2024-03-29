class ApplicationsController < ApplicationController
  include RulesControllerCommon

  before_filter :set_application_parameters, :only => [:create, :update]
  before_filter :deny_access_if_logged_in_as_application, :only => [:create, :destroy, :routing_rules]

  def set_application_parameters
    application.account_id = account.id
    application.ao_rules = get_rules :aorules
    application.at_rules = get_rules :atrules
  end

  def create
    if application.save
      redirect_to applications_path, :notice => "Application #{application.name} creaetd"
    else
      render :new
    end
  end

  def update
    if application.save
      redirect_to applications_path, :notice => "Application #{application.name} updated"
    else
      render :edit
    end
  end

  def destroy
    application.destroy
    redirect_to applications_path, :notice => "Application #{application.name} deleted"
  end

  def routing_rules
    account.app_routing_rules = get_rules :apprules

    if account.save
      redirect_to applications_path, :notice => 'Application Routing Rules were changed'
    else
      render 'index'
    end
  end
end
