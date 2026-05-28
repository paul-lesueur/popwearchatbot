class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  private

  def configure_permitted_parameters
    # Champs autorisés à l'inscription
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :company_name, :phone])
    # Champs autorisés à la modification du profil
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :company_name, :phone])
  end

  def layout_by_resource
    if devise_controller? && devise_auth_pages?
      "devise"
    else
      "application"
    end
  end

  def devise_auth_pages?
    controller_name == "sessions" ||
      (controller_name == "registrations" && action_name == "new") ||
      controller_name == "passwords"
  end
end
