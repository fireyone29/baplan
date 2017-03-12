# Streak for goals we want to do every day.
class DailyStreak < Streak
  # @see Streak.period
  def self.period
    1.day
  end
end
