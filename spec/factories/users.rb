FactoryGirl.define do
  factory :user do
    transient do
      my_password { Forgery(:basic).password }
    end

    email { Forgery(:internet).email_address }
    password { my_password }
    password_confirmation { my_password }
    confirmed_at { Date.today }
  end
end
