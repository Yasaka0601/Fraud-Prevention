FactoryBot.define do
  factory :user do
    name { "test_user" }
    role { "general" }
    email { "example@email.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end
