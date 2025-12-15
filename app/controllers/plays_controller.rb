class PlaysController < ApplicationController
  before_action :set_course
  before_action :prepare_quiz_session, only: :show

  def show
    # 今、何問目のクイズをしているのか@index に代入している。
    @index = params[:id].to_i

    # クイズを出すロジック。session[:quiz_ids]は配列なので、@index -1 をしている。
    quiz_id = session[:quiz_ids][@index -1]

    # DBから、実際のクイズを1件取得している。
    @quiz = Quiz.find(quiz_id)

    # @quiz に紐づく回答選択肢を取得。
    @choices = @quiz.choices

    # session[:answers] が nil なら []（空配列）を代わりに使う
    # その配列の「@index - 1 番目」に保存されている choice_id を取り出している
    # → すでに回答済みなら、その choice_id が入っている（＝「戻る」したときに復元できる）
    @selected_choice_id = (session[:answers] || [])[ @index - 1 ]

  end

  def answer
    index = params[:id].to_i

    # session[:answers] が nil のときだけ [] で初期化（すでに配列があればそれを使う）
    session[:answers] ||= []

    # 今の問題(index問目)でユーザーが選んだ choice_id を配列の index-1 番目に保存
    session[:answers][index - 1] = params[:selected_choice]

    # 問題番号(index)が、問題数(quiz_ids.size)以上なら「最後の問題を解き終わった」とみなす
    if index >= session[:quiz_ids].size
      redirect_to home_rooms_path# 成績表示のページは未実装なので、一旦 homeへ。
    else
      # 次の問題へリダイレクト。
      redirect_to course_play_path(@course, index + 1)
    end
  end

  private
  # どのコースをプレイ中か特定している。
  def set_course
    @course = Course.find(params[:course_id])
  end

  # 一度のプレイで出す問題リストを session に用意する。
  def prepare_quiz_session
    # クイズ開始ボタンから来たとき（?quiz_start=true 付き）####未実装####
    if params[:quiz_start].present?
      # セッションをリセットしている
      session[:quiz_ids] = nil
      session[:answers] = []
      # コースの1問目にリダイレクトしている。
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
end