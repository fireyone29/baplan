# Helpers for devise views.
module DeviseHelper
  # Render an alert with the number of errors in the form.
  #
  # @return [String] HTML for the alert banner.
  def devise_error_messages!
    return '' if resource.errors.empty?
    render 'shared/form_error_alert', count: resource.errors.count
  end

  # Render an error on a particular form field.
  #
  # @return [String] HTML for displaying an error on a field.
  def devise_errors_for(field_name)
    return '' if resource.errors[field_name].blank?
    render 'shared/form_field_error', messages: resource.errors[field_name]
  end
end
