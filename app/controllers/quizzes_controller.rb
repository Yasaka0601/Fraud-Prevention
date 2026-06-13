class QuizzesController < ApplicationController
  # 未ログインでも、クイズに挑戦できる。
  skip_before_action :authenticate_user!
  before_action :set_course
  before_action :set_quiz_data, only: [ :show, :answer ]

  def start
    session[:quiz_ids] = @course.quizzes.order("RANDOM()").pluck(:id)
    session[:answers] = []
    redirect_to course_quiz_path(@course, 1)
  end

  def show
    # ブラウザの「戻る」で回答済み状態を復元するための answer_check
    answer_check
    # 結果発表で飛ぶ先の id をセットする。
    @course_result_id = params[:result_id]&.to_i
  end

  def answer
    # ユーザーが選択肢した回答をセッションで管理。
    session[:answers][@index - 1] = Array(params[:selected_choice_id]).map(&:to_i)
    # 正誤を判定して表示するための answer_check
    answer_check

    if @index == session[:quiz_ids].size
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
    @total_questions = session[:quiz_ids].size
    @correct_count = 0

    # index_by を使うことで、キー:id 値:クイズオブジェクト のハッシュが作成される。
    quizzes_by_id = Quiz.includes(:choices).where(id: session[:quiz_ids]).index_by(&:id)

    session[:quiz_ids].each_with_index do |quiz_id, i|
      quiz = quizzes_by_id[quiz_id]
      result = QuizAnswerEvaluator.call(quiz: quiz, answer: session[:answers][i])
      @correct_count += 1 if result.correct?
    end
  end

  private
  # どのコースをプレイ中か特定している。
  def set_course
    @course = Course.find(params[:course_id])
  end

  # 今、何問目のクイズをしているのか@index に代入している。
  def set_quiz_data
    @index = params[:id].to_i
    quiz_id = session[:quiz_ids][@index - 1]
    @quiz = Quiz.find(quiz_id)
    @choices = @quiz.choices
  end

  def answer_check
    # 自分の回答を変数に代入。
    stored_answer = session[:answers][ @index - 1 ]

    # 答え合わせのインスタンスを作成し、resultに代入。
    result = QuizAnswerEvaluator.call(quiz: @quiz, answer: stored_answer)

    # 答え合わせのインスタンスのメソッドを使い、必要なデータをセットする。
    @multiple_answer = result.multiple_answer?
    @is_correct = result.correct?
    @selected_choice_ids = result.selected_ids
    @correct_choices = result.correct_choices
  end
end
