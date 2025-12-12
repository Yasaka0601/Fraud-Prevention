class Quiz < ApplicationRecord

  ##### バリデーション #####
  validates :name, presence: true, length: { maximum: 50 }
  validates :sentence, presence: true

  ##### アソシエーション #####
  has_many :choices, dependent: :destroy

  has_many :course_quizzes, dependent: :destroy
  has_many :courses, through: :course_quizzes

  has_many :quiz_categories, dependent: :destroy
  has_many :categories, through: :quiz_categories
end
