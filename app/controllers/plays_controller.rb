class PlaysController < ApplicationController
  def show
  # 選択したcourses を1件取得する。
  @course = Course.find(params[:id])

  @quiz = @course.quizzes
    .joins(:course_quizzes)
    .order('course_quizzes.question_number ASC')
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