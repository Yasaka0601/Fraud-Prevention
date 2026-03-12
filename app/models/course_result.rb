class CourseResult < ApplicationRecord
  ##### アソシエーション #####
  belongs_to :user
  belongs_to :course

  has_many :quiz_histories, dependent: :destroy

  ##### 成績の集計メソッド #####
  def self.build_from_session!(user:, course:, quiz_ids:, answers:)
    # 引数で受け取った quiz_ids(配列) の要素数を代入。
    total_questions = quiz_ids.size

    ##### メソッドのベースとなるオブジェクトを作成。#####
    # 受け取った引数や、上記の変数で CourseResult モデルのオブジェクトを生成。
    course_result = CourseResult.create!(
      user: user,
      course: course,
      correct_count: 0,
      total_questions: total_questions,
      finished_at: Time.current
    )

    # クイズ履歴、選択肢を作成
    tally = course_result.build_quiz_histories!(quiz_ids: quiz_ids, answers: answers)

    # 正解数を最新の状態にアップデート
    course_result.update!(correct_count: tally[:correct_count])

    # ユーザーの合計ポイントに加算
    user.increment!(:total_point, tally[:earned_point]) if tally[:earned_point].positive?

    # 成績履歴を20件に制限（21件目以降は古いのを削除
    user.course_results.order(created_at: :desc).offset(20).delete_all

    # コース挑戦の記録を作成
    course_result.course_challenge_record

    # メソッドの戻り値
    course_result
  end

  ##### クイズ履歴を作成し、正解数・獲得ポイントを返すメソッド #####
  def build_quiz_histories!(quiz_ids:, answers:)
    correct_count = 0
    earned_point = 0

    # 履歴を作成する全クイズをまとめて取得。
    quizzes = Quiz.where(id: quiz_ids).index_by(&:id)

    quiz_ids.each_with_index do |quiz_id, index|
      quiz = quizzes[quiz_id]
      evaluation = QuizAnswerEvaluator.call(quiz: quiz, answer: answers[index])

      # クイズ１問分の履歴を作成
      quiz_history = quiz_histories.create!(user: user, quiz: quiz)

      # クイズの選択肢の履歴を作成
      evaluation.selected_ids.each do |choice_id|
        quiz_history.quiz_history_choices.create!(choice_id: choice_id)
      end

      # 正解なら正解数とポイントを加算
      if evaluation.correct?
        correct_count += 1
        earned_point += quiz.give_point.to_i
      end
    end

    # メソッドの戻り値
    { correct_count: correct_count, earned_point: earned_point }
  end

  ##### コース挑戦履歴及び、全問正解の記録を作成 #####
  def course_challenge_record
    challenge = course_challenge_create

    # 全問正解なら、conquered_at を作成、そうでなければ return する。
    return unless correct_count == total_questions
    UserCourseChallenge.where(id: challenge.id, conquered_at: nil).update_all(conquered_at: Time.current, updated_at: Time.current)
  end

  ##### ポイントを加算するメソッド #####
  # 責務「そのコース全体で何ポイント獲得したか」QuizHistory の earned_point メソッドを使用。
  def earned_point_total
    quiz_histories.sum(&:earned_point)
  end

  private

  ##### コース挑戦履歴を作成 #####
  def course_challenge_create
    # find_or_create_by! は該当レコードを探して、なければ作成するというメソッド。
    UserCourseChallenge.find_or_create_by!(user: user, course: course)
    # 競合による重複登録を防ぐ
  rescue ActiveRecord::RecordNotUnique
    UserCourseChallenge.find_by!(user: user, course: course)
  end
end
