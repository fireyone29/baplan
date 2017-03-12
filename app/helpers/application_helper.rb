# Helpers for all views.
module ApplicationHelper
  # Only return the flash messages that have interesting information
  # for the user.
  def flash_messages
    {
      alert: flash[:alert],
      notice: flash[:notice],
      success: flash[:success],
      error: flash[:error]
    }.delete_if { |_, v| v.blank? }
  end
end
