class Streak < ApplicationRecord
  belongs_to :goal

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :positive_streak

  after_save :update_longest_streak
  after_destroy :check_longest_streak

  class StreakError < StandardError; end
  class MergeError < StreakError; end
  class SplitError < StreakError; end

  # The length added to the streak each time you execute on the goal.
  def self.period
    raise NotImplementedError, 'Not available for base Streak.'
  end

  def period
    self.class.period
  end

  # The length of this streak (inclusive).
  #
  # @return [Integer] length of the streak.
  def length
    date_difference(start_date, end_date) + 1.day
  end

  def current?
    end_date >= Time.zone.now.to_date
  end

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
      date <= end_date && date >= start_date
    end
  end

  def execute!(date)
    #TODO
    raise 'not updated' unless execute(date)
  end

  # Udate this streak by undo an execution.
  #
  # Only accepts updates which leave the streak contiguous.
  #
  # @param date [Date] The date of the execution to be undone.
  # @return [Boolean] True if successful.
  def unexecute(date)
    if date > end_date - period && date <= end_date
      self.end_date -= period
      save_or_destroy
    elsif date < start_date + period && date >= start_date
      self.start_date += period
      save_or_destroy
    else
      date > end_date || date < start_date
    end
  end

  def unexecute!(date)
    #TODO
    raise 'not updated' unless unexecute(date)
  end

  # Update this streak by combining it with another streak.
  #
  # Only accepts updates which are contiguous with this streak.
  #
  # @param other_streak [Streak] The streak to merge into this
  #   one. Destroyed on success.
  # @param and_execute [Boolean] Execute the period between the two
  #   streaks.
  # @raise [Streak::MergeError] If the merge can not be completed.
  def merge!(other_streak, and_execute: false)
    unless other_streak.is_a? self.class
      raise MergeError, 'Will not merge different types of streaks'
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
      raise MergeError, 'Range is disjoint.'
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
  # @raise [SplitError] If date is not within the streak.
  def split!(date)
    if (date < start_date + period && date >= start_date) ||
       (date > end_date - period && date <= end_date)
      return unexecute!(date)
    elsif date < start_date || date > end_date
      raise SplitError, 'Invalid split'
    end

    # Needs to find where to start the split (e.g. for weekly streaks)
    days_to_start = (date - start_date).to_i.days
    periods = days_to_start / period
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

  def positive_streak
    errors.add(:base, :negative_druation) if end_date < start_date
  end

  # If the streak has been updated to have no length, just deleted
  # since it contains no information. Otherwise, save.
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
      return goal.update_attribute(:longest_streak_length, length)
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

    if old_length > 0 && length < goal.longest_streak_length &&
       old_length == goal.longest_streak_length
      # this streak might have been the longest streak, which would
      # mean we need to reduce the longest streak... resync longest
      # streak length
      goal.reset_longest_streak
    end
  end

  def date_difference(sdate, edate)
    (edate - sdate).to_i.days
  end

  # TODO possible way of dealing with months and prettying up code,
  # return the date plus the result of multiplying time by
  # multiplier.
  #
  # TODO make class method?
  def add_multiple_of_time(date, time, multiplier = 1)
    (date + (time.seconds * multiplier).seconds).to_date
  end
end
