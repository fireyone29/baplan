# Controllers for manipulating streaks.
class StreaksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal
  before_action :set_date, only: [:execute, :unexecute]
  before_action :set_referer_path, only: [:execute, :unexecute]
  after_action :save_previous_url, only: [:execute_form, :unexecute_form]

  # Find and return any streaks for the specified goal that match the
  # provided parameters.
  def find
    find_params = params.slice(:end_date, :start_date).permit!
    find_params.transform_values! { |v| helpers.date_param_to_range(v) }
    @streaks = Streak.where(goal_id: @goal.id).where(find_params)
  end

  # Update the goal with an execution on the provided date.
  def execute
    @goal.update_or_create!(@date)
    if @referer_path == goal_execute_path(@goal)
      redirect_to session[:streaks_previous_url]
    else
      redirect_to @referer_path
    end
  end

  # Update the goal with an unexecution on the provided date.
  def unexecute
    Streak.where(goal_id: @goal.id)
          .where('start_date <= ? AND end_date >= ?', @date, @date)
          .each { |s| s.split!(@date) }
    if @referer_path == goal_unexecute_path(@goal)
      redirect_to session[:streaks_previous_url]
    else
      redirect_to @referer_path
    end
  end

  # No-op backer for the execute form route
  def execute_form(); end

  # No-op backer for the unexecute form route
  def unexecute_form(); end

  private

  # Make the relevant goal available.
  #
  # Alert and redirect if the goal doesn't belong to the user.
  def set_goal
    params.require(:goal_id)
    @goal = Goal.find(params[:goal_id])

    # where a particular goal is set, require it to belong to the
    # logged in user
    opts = { alert: 'You do not have access to that!' }
    redirect_to(goals_url, opts) unless current_user == @goal.user
  end

  # Make the relevant date available from parameters.
  def set_date
    date = params[:date]
    if date.nil?
      @date = Time.zone.today
    elsif date.is_a? ActionController::Parameters
      @date = Date.new(date[:year].to_i, date[:month].to_i, date[:day].to_i)
    else
      raise ActionController::BadRequest, 'Invalid date parameter.'
    end
  rescue ArgumentError => e
    # invalid date, reraise BadRequest
    raise ActionController::BadRequest, e.to_s, e.backtrace
  end

  # Save the referrer from the form controllers.
  def save_previous_url
    session[:streaks_previous_url] = URI(request.referer || '').path
  end

  # Save the referrer.
  def set_referer_path
    @referer_path = URI(request.referer || '').path
  end
end
