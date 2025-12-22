class PlaysController < ApplicationController
  before_action :set_course
  before_action :prepare_quiz_session, only: :show
  before_action :set_index, :set_quiz_id, :set_quiz, :set_choices

  def show
    # 正解が、２個以上なら、複数選択問題とみなす。真偽値を格納。
    @multiple_answer = @choices.where(is_correct: true).count > 1

    # 自分の回答を変数に代入。
    stored_answer = (session[:answers] || [])[ @index - 1 ]

    if @multiple_answer
      ##### 複数選択肢の場合。 #####
      # 自分の回答を整数 id に変換して@selected_choice_ids に代入。
      @selected_choice_ids = Array(stored_answer).map(&:to_i)
      if @selected_choice_ids.present?
        # 正解の選択肢をid に変換して correct_ids に代入。
        correct_ids = @choices.where(is_correct: true).pluck(:id)
        # 正解の選択肢を @multi_correct_choices に代入。
        @multi_correct_choices = @choices.where(id: correct_ids)
        # 答え合わせをしている。真偽値を格納。
        @is_correct = (@selected_choice_ids.sort == correct_ids.sort)
      end
    else
      ##### 単一選択の場合 #####
      # 自分の回答を @selected_choice_id に代入。
      @selected_choice_id = stored_answer
      if @selected_choice_id.present?
        # 自分の選択肢を selected_choice に代入。
        selected_choice = @choices.find_by(id: @selected_choice_id)
        # 正解の選択肢を correct_choice に代入。
        correct_choice = @choices.find_by(is_correct: true)
        # 正解の選択肢を @correct_choice に代入。
        @correct_choice = correct_choice
        # 答え合わせをしている。
        @is_correct = (selected_choice == correct_choice)
      end
    end
  end

  def answer

    # session[:answers] が nil のときだけ [] にする。（エラー回避のため）
    session[:answers] ||= []

    if @choices.where(is_correct: true).count > 1
      ##### 複数選択問題（チェックボックス）の場合 #####
      # params[:selected_choice_ids] は ["3", "5", ...] みたいな配列で来る想定
      selected_ids = Array(params[:selected_choice_ids]).map(&:to_i).uniq
      # 回答した配列を、session[:answers] に格納。
      session[:answers][@index - 1] = selected_ids
    else
      # 今の問題(index問目)でユーザーが選んだ choice_id を配列の index-1 番目に保存
      session[:answers][@index - 1] = params[:selected_choice]
    end
    redirect_to course_play_path(@course, @index)
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