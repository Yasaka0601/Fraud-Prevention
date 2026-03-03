class QuizHistory < ApplicationRecord
  ##### アソシエーション #####
  belongs_to :user
  belongs_to :course_result
  belongs_to :quiz

  has_many :quiz_history_choices, dependent: :destroy
  has_many :choices, through: :quiz_history_choices

  # QuizHistory は、自分の持っているデータを QuizAnswerEvaluator に渡して採点してもらう。
  # 責務「1問分の履歴が正解か判定」
  def correct?
    result = QuizAnswerEvaluator.call(
      # この履歴がどの問題か
      quiz: quiz,
      # この履歴で実際に選ばれた choice の id 一覧
      answer: choices.pluck(:id)
    )

    result.correct?
  end

  # 上記の correct? を使ってポイントを与えている。
  # 責務「1問分で何ポイント獲得したか」
  def earned_point
    correct? ? quiz.give_point.to_i : 0
  end
end
