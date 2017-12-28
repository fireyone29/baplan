FactoryBot.define do
  factory :user do
    transient do
      my_password { Faker::Internet.password }
    end

    email { Faker::Internet.safe_email }
    password { my_password }
    password_confirmation { my_password }
    confirmed_at { Time.zone.today }
  end
end
