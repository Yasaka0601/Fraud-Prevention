class QuizzesController < ApplicationController
  # 未ログインでも、クイズに挑戦できる。
  skip_before_action :authenticate_user!, only: [ :show, :answer, :guest_result ]

  before_action :set_course
  before_action :prepare_quiz_session, only: :show
  before_action :set_index, :set_quiz_id, :set_quiz, :set_choices, only: [ :show, :answer ]

  def show
    # 答え合わせのメソッドを実行（ブラウザの「戻る」で回答済みを復元）
    answer_check
    # 最後の問題用に、「結果発表」で飛ぶ先の id を覚えておく
    @course_result_id = params[:result_id].presence&.to_i
  end

  def answer
    # session[:answers] が nil のときだけ [] にする。（エラー回避のため）
    session[:answers] ||= []

    if @quiz.multiple_answer?
      ##### 複数選択問題の場合 #####
      # ユーザーが選択した回答 params[:selected_choice_ids]を整形して、変数に代入。
      selected_ids = Array(params[:selected_choice_ids]).map(&:to_i).uniq
      # 整形した回答を、session[:answers] に格納。
      session[:answers][@index - 1] = selected_ids
    else
      ##### 単一選択問題の場合 #####
      # 単一問題は、を session[:answers] に格納。
      session[:answers][@index - 1] = params[:selected_choice]
    end

    # 答え合わせをするメソッドを実行
    answer_check

    # コースの最後、途中で条件を分岐。
    if @index >= session[:quiz_ids].size
      # コースの最後の場合。
      if user_signed_in?
        # build_from_session! に引数を与え、生成したオブジェクトを変数に代入。
        course_result = CourseResult.build_from_session!(
          user: current_user,
          course: @course,
          quiz_ids: session[:quiz_ids],
          answers: session[:answers]
        )
        flash[:new_badges] = course_result.newly_granted_badges.map(&:badge_type)
        redirect_to course_quiz_path(@course, @index, result_id: course_result.id)
      else
        # 未ログインの場合 guest_result: true はクエリパラメータ
        redirect_to course_quiz_path(@course, @index, guest_result: true)
      end
    else
      # 次の問題へリダイレクトは同期通信。回答は非同期通信。
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to course_quiz_path(@course, @index) }
      end
    end
  end

  # 未ログインの処理。
  def guest_result
    quiz_ids = Array(session[:quiz_ids])
    answers  = Array(session[:answers])

    @total_questions = quiz_ids.size
    @correct_count = 0

    # index_by を使うことで、キーid のクイズオブジェクトができる。
    quizzes_by_id = Quiz.includes(:choices).where(id: quiz_ids).index_by(&:id)

    quiz_ids.each_with_index do |quiz_id, i|
      quiz = quizzes_by_id[quiz_id]
      result = QuizAnswerEvaluator.call(quiz: quiz, answer: answers[i])
      @correct_count += 1 if result.correct?
    end
  end

  private
  # どのコースをプレイ中か特定している。
  def set_course
    @course = Course.find(params[:course_id])
  end

  # 一度のプレイで出す問題リストを session に用意する。
  def prepare_quiz_session
    # クイズ開始ボタンから来たとき（クエリパラメータに quiz_start=true 付き）
    if params[:quiz_start].present?
      # セッションをリセットしている
      session[:quiz_ids] = nil
      session[:answers] = []
      # courses/:course_id/play/:id にリダイレクトしている。
      redirect_to course_quiz_path(@course, 1)
      # redirect なので return で終了させる必要がある。
      return
    end

    # session[:quiz_ids] が空の場合、コース内のクイズをランダムに並べて、idだけの配列にする。
    if session[:quiz_ids].blank?
      # コース内のクイズをランダム順にして、idだけの配列にする。
      session[:quiz_ids] = @course.quizzes.order("RANDOM()").pluck(:id)
    end
  end

  # 今、何問目のクイズをしているのか@index に代入している。
  def set_index
    @index = params[:id].to_i
  end

  # クイズを出すロジック。session[:quiz_ids]は配列なので、@index -1 をしている。
  def set_quiz_id
    @quiz_id = session[:quiz_ids][@index - 1]
  end

  # DBから、実際のクイズを1件取得している。
  def set_quiz
    @quiz = Quiz.find(@quiz_id)
  end

  # @quiz に紐づく回答選択肢を取得。
  def set_choices
    @choices = @quiz.choices
  end

  # QuizAnswerEvaluator で答え合わせをしたものをインスタンス変数に渡す。
  def answer_check
    # 自分の回答を変数に代入。
    stored_answer = (session[:answers] || [])[ @index - 1 ]

    # 答え合わせのクラス QuizAnswerEvaluator を呼び出している
    result = QuizAnswerEvaluator.call(
      quiz: @quiz,
      answer: stored_answer
    )

    # multiple_answer? と correct? メソッドは QuizAnswerEvaluator の Result で作成したメソッド。
    @multiple_answer = result.multiple_answer?
    @is_correct = result.correct?

    if @multiple_answer
      ##### 複数選択肢の場合。 #####
      # result が持つ selected_ids を @selected_choice_ids に代入。
      @selected_choice_ids = result.selected_ids
      @multi_correct_choices = result.correct_choices
    else
      ##### 単一選択の場合 #####
      @selected_choice_id = result.selected_ids.first
      @correct_choice = result.correct_choices.first
    end
  end
end
