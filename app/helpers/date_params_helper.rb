# Helpers for parsing and generating various date formats from request params.
module DateParamsHelper
  # Parse a string date param into either a date or a range of dates.
  #
  # Accepts normal date strings as well as yyyy-mm and yyyy formats.
  #
  # @param date [String] The date to parse.
  # @return [Date|Date..Date] The dates logically covered by the date
  #   provided.
  # @raise [ArgumentError] If a parsing error occurs.
  def date_param_to_range(date)
    unless date.is_a? String
      raise ArgumentError, "Can only parse strings, not #{date}:#{date.class}"
    end

    split_count = date.split('-').count
    if split_count == 3
      # These won't always be dates, but let #to_date handle that.
      date.to_date
    elsif split_count == 2
      begin_date = Date.strptime(date, '%Y-%m')
      begin_date...begin_date.next_month
    elsif split_count == 1
      begin_date = Date.strptime(date, '%Y')
      begin_date...begin_date.next_year
    else
      raise ArgumentError, "Invalid date format for '#{date}'"
    end
  end
end
