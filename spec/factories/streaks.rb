FactoryGirl.define do
  factory :streak do
    start_date { rand(1..100).days.ago }
    end_date { start_date + rand(15..25).days }

    goal
  end

  factory :daily_streak, parent: :streak, class: 'DailyStreak' do; end

  # TODO: should only have valid start/end dates (muliples of a week)
  # and ensure streak is multiple weeks
  factory :weekly_streak, parent: :streak, class: 'WeeklyStreak' do; end
end
