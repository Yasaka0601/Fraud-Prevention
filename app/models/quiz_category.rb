class QuizCategory < ApplicationRecord

  ##### バリデーション #####
  validates :quiz_id, presence: true
  validates :category_id, presence: true

  ##### アソシエーション #####

  belongs_to :quiz
  belongs_to :category
end
