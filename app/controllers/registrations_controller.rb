class RegistrationsController < Devise::RegistrationsController
  private

  def after_update_path_for(_resource)
    deadlines_path
  end
end
