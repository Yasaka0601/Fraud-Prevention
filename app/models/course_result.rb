class CourseResult < ApplicationRecord
  ##### アソシエーション #####
  belongs_to :user
  belongs_to :course

  has_many :quiz_histories, dependent: :destroy

  ##### 成績の集計メソッド #####
  def self.build_from_session!(user:, course:, quiz_ids:, answers:)
    # 引数で受け取った quiz_ids(配列) の要素数を代入。
    total_questions = quiz_ids.size
    # 正解数をカウントする変数。
    correct_count = 0
    # ポイントをカウントする変数。
    get_point = 0

    ##### メソッドのベースとなるオブジェクトを作成。#####
    # 受け取った引数や、上記の変数で CourseResult モデルのオブジェクトを生成。
    course_result = CourseResult.create!(
      user: user,
      course: course,
      correct_count: 0,
      total_questions: total_questions,
      started_at: nil, # started_at はいらない。
      finished_at: Time.current
    )

    ##### クイズ、ユーザー、回答の選択肢を保存する。#####
    # each_with_index は 要素と何番目か (index) を一緒にループさせる。
    quiz_ids.each_with_index do |quiz_id, index|
      ##### クイズを取得し、1問分の回答履歴（quiz_history）を作成 #####
      # quiz_id を使って DB からクイズを取得している。
      quiz = Quiz.find(quiz_id)

      # クイズ１問分の履歴を生成。
      quiz_history = course_result.quiz_histories.create!(
        user: user,
        quiz: quiz
      )

      ##### ユーザーの回答を記録する #####
      # ユーザーの回答を整数のid配列にして selected_ids に代入。
      selected_ids = Array(answers[index]).map(&:to_i).uniq.sort

      # 選択した choice_id を quiz_history_choices として保存
      selected_ids.each do |choice_id|
        quiz_history.quiz_history_choices.create!(choice_id: choice_id)
      end

      ##### 答え合わせ #####
      # 正解の選択肢を取得し、id を抽出し、ソートして代入。
      correct_ids = quiz.choices.where(is_correct: true).pluck(:id).sort

      # 答え合わせをしている。正解であれば true
      if selected_ids == correct_ids
        correct_count += 1 # 正解数に 1 を追加。
        get_point += quiz.give_point.to_i # 正解したクイズのポイントを追加。
      end
    end
    # 正解数を最新の状態にアップデート
    course_result.update!(correct_count: correct_count)

    ##### ポイント計算 #####
    # ユーザーの total_point にget_point を加算。positive? でポイントが 1 以上か判定。
    if get_point.positive?
      # increment! は ActiveRecord の数値カラムを加算し、保存するメソッド。
      user.increment!(:total_point, get_point)
    end

    # 成績履歴を20件に制限（21件目以降は古いのを削除、21件目以降が excess に代入される。
    excess = user.course_results.order(created_at: :desc).offset(20)
    excess.delete_all

    # コース挑戦の記録を作成
    course_result.course_challenge_record

    # メソッドの戻り値
    course_result
  end

  ##### コース挑戦履歴及び、全問正解の記録を作成 #####
  def course_challenge_record
    challenge = course_challenge_create

    # 全問正解なら、conquered_at を作成、そうでなければ return する。
    return unless correct_count == total_questions
    UserCourseChallenge.where(id: challenge.id, conquered_at: nil).update_all(conquered_at: Time.current, updated_at: Time.current)
  end

  private

  ##### コース挑戦履歴を作成 #####
  def course_challenge_create
    UserCourseChallenge.find_or_create_by!(user: user, course: course)
  # 例外処理。
  rescue ActiveRecord::RecordNotUnique
    UserCourseChallenge.find_by!(user: user, course: course)
  end
end
