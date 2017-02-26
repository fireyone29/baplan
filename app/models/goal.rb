class Goal < ApplicationRecord
  belongs_to :user
  has_many :streaks, dependent: :destroy

  validates :description, presence: true, allow_blank: false
  validates_uniqueness_of :description, scope: :user_id
  enum frequency: [:daily, :weekly]

  # Record a execution of this goal on the given date.
  #
  # @param date [Date] The date of the execution.
  # @raise [various] If the update fails.
  def update_or_create!(date)
    streaks = relevant_streaks(date)
    if streaks.empty?
      new_streak(start_date: date).save!
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
      start_date: date..date+streak_class.period).or(
      # date in period after end
      Streak.where(end_date: date-streak_class.period..date).or(
      # date is within the streak
      Streak.where("start_date < ? AND end_date > ?", date, date))
    ).where(goal_id: self.id)
  end

  private

  # Build (but don't save or create) a new streak of the correct type.
  #
  # @return [Streak] The new streak.
  def new_streak(data = {})
    params = data.merge({goal_id: self.id})
    if params[:start_date]
      params[:end_date] ||= params[:start_date] + streak_class.period - 1.day
    end
    streak_class.new(params)
  end

  def streak_class
    case self.frequency.to_sym
    when :daily
      DailyStreak
    when :weekly
      WeeklyStreak
    end
  end
end
