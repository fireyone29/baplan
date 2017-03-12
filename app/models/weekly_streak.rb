# Streak for goals we want to do each week.
class WeeklyStreak < Streak
  # @see Streak.period
  def self.period
    1.week
  end
end
