class QuizCategory < ApplicationRecord

  ##### バリデーション #####
  validates :quiz, presence: true
  validates :category, presence: true

  ##### アソシエーション #####

  belongs_to :quiz
  belongs_to :category
end
