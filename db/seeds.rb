# This file should contain all the record creation needed to seed the
# database with its default values.  The data can then be loaded with
# the rails db:seed command (or created alongside the database with
# db:setup).

def create_testing_data
  password = 'testing'
  # user with no goals
  User.create(email: 'empty@example.com',
              password: password,
              password_confirmation: password,
              confirmed_at: Time.zone.today)

  # user with many goals
  user = User.create(email: 'test@example.com',
                     password: password,
                     password_confirmation: password,
                     confirmed_at: Time.zone.today)
  1.upto(20) do |i|
    Goal.create(user_id: user.id,
                description: "action #{i}",
                frequency: :daily)
  end

  # TODO: user_with_streaks
end

case Rails.env
when 'production'
  create_testing_data if ENV['YES_REALLY_PUT_TEST_DATA_IN_PROD'] == 'for real'
when 'development'
  create_testing_data
end

puts 'DB successfully seeded'
