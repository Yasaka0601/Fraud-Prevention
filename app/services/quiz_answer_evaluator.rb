# クイズの正誤判定などを行うクラス
class QuizAnswerEvaluator

  def self.call(quiz:, answer:)
    self.new(quiz:, answer:)
  end

  def initialize(quiz:, answer:)
    @quiz = quiz
    @answer = answer
  end

  # 複数選択肢のクイズなのか判定
  def multiple_answer?
    @quiz.choices.where(is_correct: true).count > 1
  end

  # ユーザーが選択した回答一覧
  def selected_ids
    @selected_ids ||= Array(@answer).sort
  end

  # 正解選択肢の id 一覧
  def correct_ids
    @correct_ids ||= @quiz.choices.where(is_correct: true).pluck(:id).sort
  end

  # 正解選択肢のオブジェクト一覧
  def correct_choices
    @correct_choices ||= @quiz.choices.where(id: correct_ids)
  end

  # 正誤判定のメソッド
  def correct?
    selected_ids.present? ? selected_ids == correct_ids : nil
  end

end
