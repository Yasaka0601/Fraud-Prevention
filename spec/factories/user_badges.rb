FactoryBot.define do
  factory :user_badge do
    association :user
    badge_type { :white_belt }
    notified_at { nil }
  end
end
