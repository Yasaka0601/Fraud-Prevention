class ResultsController < ApplicationController

  def index
    # DB からユーザーのコース成績を取得し、インスタンス変数に代入。
    @course_results = current_user.course_results
                                  .includes(:course) # N + 1 対策済み。
                                  .order(created_at: :desc) # 作成降順にしている。
                                  .limit(10) # 最新の１０件を取得。
  end

  def show
    # コース成績の一つを選択し、インスタンス変数に代入。
    @course_result = current_user.course_results.find(params[:id])
    # コース成績に紐づいているユーザーの回答を取得。N + 1 対策済み。
    @quiz_histories = @course_result.quiz_histories
                                    .includes(quiz: :choices, quiz_history_choices: :choice)

    # URL 直打ち対策の為、ここでもセッションを初期化。
    session[:quiz_ids] = nil
    session[:answers]  = []
  end
end
