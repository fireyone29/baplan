# Record for tracking when a goal has been executed.
#
# Track ranges of executions rather than individual dates in order to
# conserve space in the DB.
class Streak < ApplicationRecord
  belongs_to :goal

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :positive_streak

  after_save :update_longest_streak
  after_destroy :check_longest_streak

  # Error raised when updating a streak fails.
  class UpdateError < StandardError; end

  # The length added to the streak each time you execute on the goal.
  def self.period
    raise NotImplementedError, 'Not available for base Streak.'
  end

  # @see .period
  def period
    self.class.period
  end

  # The length of this streak (inclusive).
  #
  # @return [Integer] length of the streak.
  def length
    date_difference(start_date, end_date) + 1.day
  end

  # Check if this streak has been executed for today.
  #
  # @return [Boolean] True if the streak's end date is on or beyond
  #   today.
  def current?
    end_date >= Time.zone.now.to_date
  end

  # Check if this streak has been executed recently, i.e. in within
  # one period.
  #
  # @return [Boolean] True if the streak's end date is within on
  #   period of today.
  def recent?
    end_date >= Time.zone.now.to_date - period
  end

  # Udate this streak with a new execution.
  #
  # Only accepts updates which are contiguous with this streak.
  #
  # @param date [Date] The date of the execution.
  # @return [Boolean] True if successful.
  def execute(date)
    if date <= end_date + period && date > end_date
      self.end_date += period
      save
    elsif date >= start_date - period && date < start_date
      self.start_date -= period
      save
    else
      inside_streak?(date)
    end
  end

  # Execute this streak, raise if update fails.
  #
  # @see #execute
  #
  # @raise [UpdateError] If the execution fails.
  def execute!(date)
    raise UpdateError, 'Execute failed' unless execute date
  end

  # Update this streak by undoing an execution.
  #
  # Only accepts updates which leave the streak contiguous.
  #
  # @param date [Date] The date of the execution to be undone.
  # @return [Boolean] True if successful.
  def unexecute(date)
    if just_inside_end?(date)
      self.end_date -= period
      save_or_destroy
    elsif just_inside_start?(date)
      self.start_date += period
      save_or_destroy
    else
      !inside_streak?(date)
    end
  end

  # Unexecute this streak, raise if update fails.
  #
  # @see #unexecute
  #
  # @raise [UpdateError] If the unexecution fails.
  def unexecute!(date)
    raise UpdateError, 'Unexecute failed' unless unexecute date
  end

  # Update this streak by combining it with another streak.
  #
  # Only accepts updates which are contiguous with this streak.
  #
  # @param other_streak [Streak] The streak to merge into this
  #   one. Destroyed on success.
  # @param and_execute [Boolean] Execute the period between the two
  #   streaks.
  # @raise [UpdateError] If the merge can not be completed.
  def merge!(other_streak, and_execute: false)
    unless other_streak.is_a? self.class
      raise UpdateError, 'Will not merge different types of streaks'
    end

    # addition used instead of multiplication because it results in
    # 2.day or 2.weeks instead of the integer number of seconds in
    # that time
    gap = and_execute ? (period + period) : period

    if other_streak.end_date == start_date - gap
      self.start_date = other_streak.start_date
    elsif other_streak.start_date == end_date + gap
      self.end_date = other_streak.end_date
    else
      raise UpdateError, 'Range is disjoint.'
    end

    transaction do
      save!
      other_streak.destroy!
    end
  end

  # Update this streak by splitting it into two streaks.
  #
  # Will unexecute instead of splitting when appropriate.
  #
  # @param date [Date] The date to split on, will no longer be part of
  #   any streak.
  # @return [Streak] Newly created streak if appropriate, otherwise
  #   nil.
  # @raise [UpdateError] If date is not within the streak.
  def split!(date)
    return unexecute! date if just_inside_start?(date) || just_inside_end?(date)
    raise UpdateError, 'Invalid split' unless inside_streak?(date)

    # Needs to find where to start the split (e.g. for weekly streaks)
    periods = date_difference(start_date, date) / period
    new_end = add_multiple_of_time(start_date, period, periods)

    new_streak = nil
    transaction do
      new_streak = self.class.create!(goal_id: goal_id,
                                      start_date: start_date,
                                      end_date: new_end)
      self.start_date = new_end + period
      save!
    end
    new_streak
  end

  private

  # Add an error to the model if the streak's length would be
  # negative.
  def positive_streak
    errors.add(:base, :negative_druation) if end_date < start_date
  end

  # If the streak has been updated to have no length, just deleted
  # since it contains no information. Otherwise, save.
  #
  # @return [Boolean] True if relevant action succeeded.
  def save_or_destroy
    if length < 1.day
      destroy
    else
      save
    end
  end

  # On an update, set the goal's longest streak length if necessary.
  def update_longest_streak
    if length > goal.longest_streak_length
      goal.longest_streak_length = length
      return goal.save
    end

    check_longest_streak
  end

  # Handle updating the goal's longest streak when streak length has
  # been reduced (e.g. by destroying this streak).
  def check_longest_streak
    old_length = 0
    if start_date_was && end_date_was
      old_length = date_difference(start_date_was, end_date_was) + 1.day
    end

    if old_length.positive? && length < goal.longest_streak_length &&
       old_length == goal.longest_streak_length
      # this streak might have been the longest streak, which would
      # mean we need to reduce the longest streak... resync longest
      # streak length
      goal.reset_longest_streak
    end
  end

  # Check if the date is within the streak.
  #
  # @param date [Date] The date to check.
  # @return [Boolean] True if the date is within the streak.
  def inside_streak?(date)
    date <= end_date && date >= start_date
  end

  # Check if the date is within the first period of the streak.
  #
  # @param date [Date] The date to check.
  # @return [Boolean] True if the date is within the first period of
  #   the streak.
  def just_inside_start?(date)
    date < start_date + period && date >= start_date
  end

  # Check if the date is within the last period of the streak.
  #
  # @param date [Date] The date to check.
  # @return [Boolean] True if the date is within the last period of
  #   the streak.
  def just_inside_end?(date)
    date > end_date - period && date <= end_date
  end

  # Return the number of time between two dates.
  #
  # @param sdate [Date] The start of the range.
  # @param edate [Date] The end of the range.
  # @return [FixNum] Number of seconds between the dates.
  def date_difference(sdate, edate)
    (edate - sdate).to_i.days
  end

  # TODO: possible way of dealing with months and prettying up code,
  # return the date plus the result of multiplying time by
  # multiplier.
  #
  # TODO: make class method?
  def add_multiple_of_time(date, time, multiplier = 1)
    (date + (time.seconds * multiplier).seconds).to_date
  end
end
