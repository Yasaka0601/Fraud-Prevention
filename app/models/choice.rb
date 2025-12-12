class Choice < ApplicationRecord

  ##### バリデーション #####
  validates :quiz_id, presence: true
  validates :text, presence: true
  validates :is_correct, inclusion: { in: [true, false] }

  ##### アソシエーション #####
  belongs_to :quiz
end
