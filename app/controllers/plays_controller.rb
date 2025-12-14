class PlaysController < ApplicationController
  def show
  # 選択したcourses を1件取得。プレイ中のコースの情報を持つのが @course
  @course = Course.find(params[:id])

  @quiz = @course.quizzes
    # PostgreSQL の RANDOM という関数。
    .order("RANDOM()")
    # ランダムに並べ替えた中で、最初の1件を取得
    .first

    # &. は、セーフナビゲーション演算子という。
    # if @quiz.present? 以下の記述は、この記述と同じ意味。
    #   @choices = @quiz.choices
    # else
    #   @choices = []
    # end
    @choices = @quiz&.choices || []
  end
end