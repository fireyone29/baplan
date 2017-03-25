# Base controller for the App.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true

  before_action :configure_devise_parameters, if: :devise_controller?
  before_action :set_time_zone

  protected

  # Add allowed parameters beyond what devise uses by default.
  def configure_devise_parameters
    custom_keys = %w(time_zone)
    devise_parameter_sanitizer.permit(:account_update, keys: custom_keys)
  end

  # Set the time zone for this request based either on user
  # configuration or javascript detection. Or warn the user.
  def set_time_zone
    # Note: timezone is irrelavant when there is no current user
    # because we won't be displaying any streak information in that
    # context (which is the only time it matters).
    return unless current_user

    if current_user.time_zone.present?
      Time.zone = current_user.time_zone
    elsif cookies['time_zone'].present?
      Time.zone = cookies['time_zone']
    else
      Time.zone = nil
      flash.now[:alert] = 'Time zone not set, defaulting to GMT!'
    end
  end
end
