module GoalsHelper
  def goals_error_messages!
    return '' if @goal.errors.empty?

    count = @goal.errors.count
    html = <<-HTML
      <div class="alert alert-danger">
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
        Please fix the #{pluralize(count, "highlighted error")} and try again.
      </div>
    HTML

    html.html_safe
  end

  def goals_errors_for(field_name)
    return '' if @goal.errors[field_name].empty?

    messages = @goal.errors[field_name].map{ |msg| content_tag(:li, msg) }.join
    html = <<-HTML
      <div class="field_with_errors"><span class="help-block">
        <ul>#{messages}</ul>
      </span></div>
    HTML

    html.html_safe
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
