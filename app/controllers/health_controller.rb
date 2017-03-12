# Controller returning health information about the app.
class HealthController < ApplicationController
  # Render json with information about the running version of the app.
  def show
    health = {
      version: Rails.application.class::VERSION,
      db_version: ActiveRecord::Migrator.current_version
    }
    render json: health
  end
end
