class PlaysController < ApplicationController
  before_action :set_course
  before_action :prepare_quiz_session, only: :show
  before_action :set_index, :set_quiz_id, :set_quiz, :set_choices

  def show
    # 正解が、２個以上なら、複数選択問題とみなす。
    @multiple_answer = @choices.where(is_correct: true).count > 1
    # session[:answers] が nil なら []（空配列）を代わりに使う
    # session[:answers] が nil の場合は []（空配列）として扱うことでエラーを防ぐ。
    # その配列の「@index - 1 番目」に保存されている choice_id を取り出している
    # → すでに回答済みなら、その choice_id が入っている（＝「戻る」したときに復元できる）
    if @multiple_answer
      stored = (session[:answers] || [])[ @index - 1]
      @selected_choice_ids = Array(stored).map(&:to_i)
    else
      @selected_choice_id = (session[:answers] || [])[ @index - 1 ]
    end
  end

  def answer

    # session[:answers] が nil のときだけ [] にする。（エラー回避のため）
    session[:answers] ||= []

    if @choices.where(is_correct: true).count > 1
      ##### 複数選択問題（チェックボックス）の場合 #####

      # params[:selected_choice_ids] は ["3", "5", ...] みたいな配列で来る想定
      selected_ids = Array(params[:selected_choice_ids]).map(&:to_i).uniq

      # 正解の選択肢
      correct_ids = @choices.where(is_correct: true).pluck(:id)

      # セッションで、選んだid の配列を残しておく。
      session[:answers][@index - 1] = selected_ids

      @selected_choice_ids = selected_ids
      @multi_correct_choices = @choices.where(id: correct_ids)
      @is_correct = (selected_ids.sort == correct_ids.sort)
    else
      ##### 単一選択問題（ラジオボタン）の場合 #####
      selected_id = params[:selected_choice].presence

      # 今の問題(index問目)でユーザーが選んだ choice_id を配列の index-1 番目に保存
      session[:answers][@index - 1] = params[:selected_choice]

      @selected_choice_id = selected_id

      # /courses/:course_id/play/:id/answer から、id と body の :selected_choice を受け取る。
      selected_choice = @choices.find_by(id: params[:selected_choice])

      # 解答を取得している。
      correct_choice  = @choices.find_by(is_correct: true)

      # 正解の選択肢を @correct_choice に代入している。
      @correct_choice = correct_choice
      # 答え合わせをして、@is_correct に代入している。同じなら true、違えば false
      @is_correct = (selected_choice == correct_choice)
    end

    render :show

    # # 問題番号(index)が、問題数(quiz_ids.size)以上なら「最後の問題を解き終わった」とみなす
    # if @index >= session[:quiz_ids].size
    #   redirect_to home_rooms_path# 成績表示のページは未実装なので、一旦 homeへ。
    # else
    #   # 次の問題へリダイレクト。
    #   redirect_to course_play_path(@course, @index + 1)
    # end
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
      redirect_to course_play_path(@course, 1)
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
    @quiz_id = session[:quiz_ids][@index - 1 ]
  end

  # DBから、実際のクイズを1件取得している。
  def set_quiz
    @quiz = Quiz.find(@quiz_id)
  end

  # @quiz に紐づく回答選択肢を取得。
  def set_choices
    @choices = @quiz.choices
  end

end