class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  layout :layout_by_resource

  private

  def layout_by_resource
    if devise_controller? && devise_auth_pages?
      "devise"
    else
      "application"
    end
  end

  def devise_auth_pages?
    # Le bloc orange seulement pour connexion / inscription / mot de passe
    controller_name == "sessions" ||
      (controller_name == "registrations" && action_name == "new") ||
      controller_name == "passwords"
  end
end
