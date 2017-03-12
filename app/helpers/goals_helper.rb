# Helpers for goal views.
module GoalsHelper
  # Render an alert with the number of errors in the form.
  #
  # @return [String] HTML for the alert banner.
  def goals_error_messages!
    return '' if @goal.errors.empty?
    render 'shared/form_error_alert', count: @goal.errors.count
  end

  # Render an error on a particular form field.
  #
  # @return [String] HTML for displaying an error on a field.
  def goals_errors_for(field_name)
    return '' if !@goal.errors[field_name] || @goal.errors[field_name].empty?
    render 'shared/form_field_error', messages: @goal.errors[field_name]
  end

  # Return the length, in days, of the current streak of the given
  # goal.
  #
  # @param goal [Goal] The goal to read from.
  # @return [FixNum] Length in days of the current streak.
  def current_length(goal)
    if goal.latest_streak && goal.latest_streak.recent?
      goal.latest_streak.length / 1.day.seconds
    else
      0
    end
  end
end
