class HealthController < ApplicationController
  def show
    health = {
      version: Rails.application.class::VERSION,
      db_version: ActiveRecord::Migrator.current_version,
    }
    render json: health
  end
end
