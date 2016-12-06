module DeviseHelper
  def devise_error_messages!
    return '' if resource.errors.empty?

    count = resource.errors.count
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

  def devise_errors_for(field_name)
    return '' if resource.errors[field_name].empty?

    messages = resource.errors[field_name].map{ |msg| msg.humanize }.join(", ")
    html = <<-HTML
      <div class="field_with_errors"><span class="help-block">
        #{messages}
      </span></div>
    HTML

    html.html_safe
  end
end
