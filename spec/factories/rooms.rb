FactoryBot.define do
  factory :room do
    name { "test_room" }
    entry_word { "テストの合言葉" }
    association :host_user, factory: :user
  end
end
