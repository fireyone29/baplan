FactoryGirl.define do
  factory :goal do
    description { Forgery(:lorem_ipsum).words(4) }
    frequency { Goal.frequencies.keys.sample }

    user
  end
end
