class StreaksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal
  before_action :set_streak, only: [:edit, :destroy]
  before_action :set_date

  def create
    @goal.update_or_create!(@date)
    redirect_back fallback_location: goal_url(@goal)
  end

  def edit
    # execute a date when we think we know which streak it belongs to
    if @streak.execute(@date)
      # TODO: make sure there's no streak to join this one with?
    else
      @goal.update_or_create!(@date)
    end
    redirect_back fallback_location: goal_url(@goal)
  end

  def destroy
    @streak.split!(@date)
    # TODO: do we ever need to look for the date in another streak???
    redirect_back fallback_location: goal_url(@goal)
  end

  private

  def set_goal
    @goal = Goal.find(streak_params[:goal_id])

    # where a particular goal is set, require it to belong to the logged
    # in user
    if current_user != @goal.user
      redirect_to goals_url, alert: 'You do not have access to that!'
    end
  end

  def set_streak
    @streak = Streak.find(streak_params[:id])
    if @streak.goal_id != @goal.id
      raise ActionController::BadRequest, 'Streak and goal do not match'
    end
  end

  def set_date
    # probably not worth setting date here, browser should have
    # provided it so there aren't TZ schenanigans.
    date_str = streak_params[:date].to_s
    @date = DateTime.parse(date_str)
  rescue ArgumentError => e
    # invalid date, reraise BadRequest
    raise ActionController::BadRequest, e.to_s, e.backtrace
  end

  def streak_params
    params.require(:date)
    params.require(:goal_id)
    params
  end
end
