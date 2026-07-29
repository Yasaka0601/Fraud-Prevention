class SharedQuizzesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_quiz_data, only: [ :show, :answer ]

  def show
  end

  def answer
    answer = Array(params[:selected_choice_id]).map(&:to_i)
    result = QuizAnswerEvaluator.call(quiz: @quiz, answer: answer)

    # view で使用するインスタンス変数をセット
    @is_correct = result.correct?
    @selected_choice_ids = result.selected_ids
    @correct_choices = result.correct_choices

    respond_to do |format|
      format.turbo_stream
      format.html { render :show }
    end
  end

  private

  def set_quiz_data
    @quiz = Quiz.includes(:choices).find(params[:id])
    @choices = @quiz.choices
    @multiple_answer = @quiz.choices.where(is_correct: true).count > 1
  end
end
