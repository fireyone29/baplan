module GoalsHelper
  def goals_error_messages!
    return '' if @goal.errors.empty?

    count = @goal.errors.count
    html = <<-HTML
      <div class="alert alert-danger">
        <button type="button" class="close" aria-label="Close">
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
end
