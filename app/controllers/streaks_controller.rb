class StreaksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal
  before_action :set_date, only: [:execute, :unexecute]
  after_filter :save_previous_url

  def execute_form
  end

  def execute
    @goal.update_or_create!(@date)
    redirect_to session[:streaks_previous_url]
  end

  def unexecute_form
  end

  def unexecute
    Streak.where(goal_id: @goal.id)
      .where("start_date <= ? AND end_date >= ?", @date, @date)
      .each { |s| s.split!(@date) }
    redirect_to session[:streaks_previous_url]
  end

  private

  def set_goal
    params.require(:goal_id)
    @goal = Goal.find(params[:goal_id])

    # where a particular goal is set, require it to belong to the logged
    # in user
    if current_user != @goal.user
      redirect_to goals_url, alert: 'You do not have access to that!'
    end
  end

  def set_date
    # probably not worth setting date here, browser should have
    # provided it so there aren't TZ schenanigans.
    params.require(:date)
    date = params[:date]
    @date = Date.new(date[:year].to_i, date[:month].to_i, date[:day].to_i)
  rescue ArgumentError => e
    # invalid date, reraise BadRequest
    raise ActionController::BadRequest, e.to_s, e.backtrace
  end

  def save_previous_url
    session[:streaks_previous_url] = URI(request.referer || '').path
  end
end
