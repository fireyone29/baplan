FactoryGirl.define do
  factory :goal do
    description { Faker::Lorem.sentence(3) }
    frequency { Goal.frequencies.keys.sample }

    user
  end
end
