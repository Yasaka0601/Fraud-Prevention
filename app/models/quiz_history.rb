class QuizHistory < ApplicationRecord
  ##### アソシエーション #####
  belongs_to :user
  belongs_to :course_result
  belongs_to :quiz

  has_many :quiz_history_choices, dependent: :destroy
  has_many :choices, through: :quiz_history_choices
end
