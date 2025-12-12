class CourseQuiz < ApplicationRecord

  ##### バリデーション #####
  # 同じコースに同じクイズを２回入れない制約
  validates :quiz_id, uniqueness: { scope: :course_id }
  validates :course_id, presence: true
  validates :question_number,
    # このクイズが「コースの何問目か」を表す番号（1以上の整数だけ許可）
    numericality: { only_integer: true, greater_than: 0 },
    # question_number の被り防止の制約。
    uniqueness: { scope: :course_id },
    # question_number が nil の場合は、このバリデーション自体をスキップする
    allow_nil: true

  ##### アソシエーション #####
  belongs_to :quiz
  belongs_to :course
end
