class ResultsController < ApplicationController
  before_action :set_user

  def users
    # none はActiveRecord で空の検索結果を返す。
    @room_users = current_user.room ? current_user.room.users.order(:id) :  User.none
  end

  def index
    # クエリの生成をする。現在のユーザーの各コースの成績を検索条件に追加。
    # 以降、user_result にクエリを追加していく。
    user_result = @target_user.course_results.joins(:course)

    # ユーザーの成績の内、コースID の検索条件を追加。distinct で重複排除。
    course_ids = user_result.select(:course_id).distinct

    # ユーザーの成績が存在するコースのみを表示するインスタンス変数。
    @course_options = Course.where(id: course_ids).order(:id)

    # 成績が存在するカテゴリーを変数に代入。
    category_ids = Course.where(id: course_ids).select(:category_id).distinct

    # ユーザーの成績が存在するカテゴリーのみを表示するインスタンス変数。
    @category_options = Category.where(id: category_ids).order(:id)

    # course_id が選択された時のクエリ追加。
    user_result = user_result.where(course_id: params[:course_id]) if params[:course_id].present?

    # category_id を受け取った時のクエリ追加。
    user_result = user_result.where(courses: { category_id: params[:category_id] }) if params[:category_id].present?

    # 絞り込みの結果をインスタンス変数に代入している。N + 1 対策済み
    @course_results = user_result.includes(:course).order(created_at: :desc)
  end

  def show
    # コース成績の一つを選択し、インスタンス変数に代入。
    @course_result = @target_user.course_results.find(params[:id])

    # コース成績に紐づいているユーザーの回答を取得。N + 1 対策済み。
    @quiz_histories = @course_result.quiz_histories
                                    .includes(quiz: :choices, quiz_history_choices: :choice)

    # コースで獲得したポイントを計算している。
    @get_point = @quiz_histories.sum do |history|
      quiz = history.quiz
      selected_ids = history.choices.map(&:id).sort
      correct_ids = quiz.choices.select(&:is_correct).map(&:id).sort
      # 答え合わせをして true なら、ポイント加算。false なら 0
      selected_ids == correct_ids ? quiz.give_point.to_i : 0
    end
  end

  private

  def set_user
    # 他のユーザーを選択しなかった場合、自分のユーザーをセットする。
    if params[:user_id].blank?
      @target_user = current_user
      return
    end

    # 家族ルームに属していない場合、自分のユーザーをセット。属している場合、同じルームのユーザー達をセット。
    @target_user = current_user.room.present? ? current_user.room.users.find(params[:user_id]) : current_user
  end
end
