FactoryBot.define do
  factory :user_badge do
    association :user
    badge_type { :white_belt }
    acquired_at { Time.current }
    notified_at { nil }
  end
end
