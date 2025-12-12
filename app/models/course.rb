class Course < ApplicationRecord

  ##### バリデーション #####
  validates :category_id, presence: true
  validates :name, presence: true
  validates :max_questions, presence: true

  ##### アソシエーション #####

  belongs_to :category

  has_many :course_quizzes, dependent: :destroy
  has_many :quizzes, through: :course_quizzes
end
