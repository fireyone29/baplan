# A goal details something the user wants to do.
#
# Goal is the basic display unit for the frontend as well.
class Goal < ApplicationRecord
  belongs_to :user
  has_many :streaks, dependent: :destroy
  has_one :latest_streak, -> { order 'end_date desc' },
          inverse_of: :goal,
          class_name: 'Streak'

  validates :description,
            presence: true,
            allow_blank: false,
            uniqueness: { scope: :user_id }

  enum frequency: %i[daily weekly]

  # Record a execution of this goal on the given date.
  #
  # @param date [Date] The date of the execution.
  # @raise [various] If the update fails.
  def update_or_create!(date)
    streaks = relevant_streaks(date)
    if streaks.empty?
      create_streak!(start_date: date)
    elsif streaks.count == 1
      streaks.first.execute!(date)
    else
      streaks.first.merge!(streaks.last, and_execute: true)
    end
  end

  # Find streaks which are adjacent to the provided date
  #
  # @param date [Date] The date of the execution.
  # @return [Array<Streak>] Between zero and two relevant streaks.
  def relevant_streaks(date)
    Streak.where(
      # date in period before start
      start_date: date..date + streak_class.period
    ).or(
      # date in period after end
      Streak.where(end_date: date - streak_class.period..date).or(
        # date is within the streak
        Streak.where('start_date < ? AND end_date > ?', date, date)
      )
    ).where(goal_id: id)
  end

  # Search all associated streaks for the longest one.
  def reset_longest_streak
    streak_lengths = Streak.where(goal_id: id).map(&:length)
    self.longest_streak_length = streak_lengths.max.to_i
    save!
  end

  private

  # Create a new streak of the correct type.
  #
  # @return [Streak] The new streak.
  def create_streak!(data = {})
    params = data.merge(goal_id: id)
    if params[:start_date]
      params[:end_date] ||= params[:start_date] + streak_class.period - 1.day
    end
    streak_class.create!(params)
  end

  # Return the correct Streak class based on the frequency of the
  # goal.
  #
  # @return [Class] An appropriate streak class.
  def streak_class
    case frequency.to_sym
    when :daily
      DailyStreak
    when :weekly
      WeeklyStreak
    end
  end
end
