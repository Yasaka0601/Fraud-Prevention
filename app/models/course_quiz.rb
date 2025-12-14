class CourseQuiz < ApplicationRecord

  ##### バリデーション #####
  # 同じコースに同じクイズを２回入れない制約
  validates :quiz_id, uniqueness: { scope: :course_id }
  validates :course_id, presence: true

  ##### アソシエーション #####
  belongs_to :quiz
  belongs_to :course
end
