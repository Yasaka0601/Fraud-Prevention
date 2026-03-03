# クイズの正誤判定を行うクラス
class QuizAnswerEvaluator
  # クイズの結果を入れるための Result を定義。
  Result = Struct.new(
    :multiple_answer?,
    :selected_ids,
    :correct_ids,
    :correct_choices,
    :correct?,
    keyword_init: true
  )

  # クラスメソッド
  def self.call(quiz:, answer:)
    # QuizAnswerEvaluator.call で呼び出すことができるようにしている。
    new(quiz:, answer:).call
  end

  # クラスを new した際、インスタンス変数をセットする。
  def initialize(quiz:, answer:)
    @quiz = quiz
    @answer = answer
  end

  # private 配下の各メソッドの戻り値を集めて Result を作成している。
  def call
    Result.new(
      multiple_answer?: multiple_answer?,
      selected_ids: selected_ids,
      correct_ids: correct_ids,
      correct_choices: correct_choices,
      correct?: answered? ? selected_ids == correct_ids : nil
    )
  end

  private

  # @quiz と @answer を返す。
  attr_reader :quiz, :answer

  # 正解の選択肢が2つ以上なら true (複数選択問題)
  def multiple_answer?
    quiz.multiple_answer?
  end

  # answer を、整数の・重複なし・並び順統一済みの配列に変える
  def selected_ids
    @selected_ids ||= Array(answer).map(&:to_i).uniq.sort
  end

  # 正解選択肢の id 一覧
  def correct_ids
    @correct_ids ||= quiz.choices.where(is_correct: true).pluck(:id).sort
  end

  # 正解選択肢のオブジェクト一覧
  def correct_choices
    @correct_choices ||= quiz.choices.where(id: correct_ids)
  end

  # 未回答であれば false 回答済みであれば true
  def answered?
    selected_ids.present?
  end
end
