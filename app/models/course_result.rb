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

    # 受け取った引数や、上記の変数で CourseResult モデルのオブジェクトを生成。
    course_result = CourseResult.create!(
      user: user,
      course: course,
      correct_count: 0,
      total_questions: total_questions,
      started_at: nil,
      finished_at: Time.current
    )
    # each_with_index は 要素と何番目か (index) を一緒にループさせる。
    quiz_ids.each_with_index do |quiz_id, index|
      # quiz_id を使って DB からクイズを取得し、代入している。
      quiz = Quiz.find(quiz_id)
      # ユーザーの選択肢を整数のid配列にして selected_ids に代入。
      selected_ids = Array(answers[index]).map(&:to_i).uniq
      # コースの中の一問分の履歴を生成。
      quiz_history = course_result.quiz_histories.create!(
        user: user,
        quiz: quiz
      )

      selected_ids.each do |choice_id|
        # ユーザーが選んだ複数の選択肢（choice_id 達）を、 quiz_history_choices に全部保存している
        quiz_history.quiz_history_choices.create!(choice_id: choice_id)
      end

      # 正解の選択肢を取得し、id を抽出し、ソートして代入。
      correct_ids = quiz.choices.where(is_correct: true).pluck(:id).sort
      # 答え合わせをしている。正解であれば true
      if selected_ids.sort == correct_ids
        correct_count += 1 #正解数に 1 を追加。
        get_point += quiz.give_point.to_i #正解したクイズのポイントを追加。
      end
    end
    # 正解数を最新の状態にアップデート
    course_result.update!(correct_count: correct_count)

    # ユーザーの total_point にget_point を加算。positive? でポイントが 1 以上か判定。
    if get_point.positive?
      # increment! は ActiveRecord の数値カラムを加算し、保存するメソッド。
      user.increment!(:total_point, get_point)
    end
    # メソッドの戻り値
    course_result
  end
end
