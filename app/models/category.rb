class Category < ApplicationRecord

  ##### バリデーション #####
  validates :name, presence: true, length: { maximum: 50 }

  ##### アソシエーション #####
  has_many :quiz_categories, dependent: :destroy
  has_many :quizzes, through: :quiz_categories

  has_many :courses, dependent: :destroy
end
