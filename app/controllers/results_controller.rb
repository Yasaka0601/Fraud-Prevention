class ResultsController < ApplicationController
  before_action :set_target_user

  def users
    # none はActiveRecord で空の検索結果を返す。
    @room_users = current_user.room ? current_user.room.users.order(:id).page(params[:page]).per(10) :  User.none
  end

  # 対象ユーザーの成績を取り出す。絞り込み用の選択肢を作り、params に応じて絞った結果を一覧表示する
  def index
    # このユーザーの成績一覧を、あとでコース情報でも絞り込める形で用意する。検索のベースを作成。
    results_scope = base_results_scope

    # view 用の選択肢データ（プルダウン）をセットしている
    set_filter_options(results_scope)

    # プルダウンの params を受け取って検索条件を絞り込む。
    results_scope = apply_filters(results_scope)

    # 最終的な絞り込みの結果。
    @course_results = paginated_results(results_scope)
  end

  def show
    # コース成績の一つを選択し、インスタンス変数に代入。
    @course_result = @target_user.course_results.find(params[:id])

    # コース成績に紐づいているユーザーの回答を取得。N + 1 対策済み。
    @quiz_histories = @course_result.quiz_histories
                                    .includes(quiz: :choices, quiz_history_choices: :choice)

    point_calculation

    ##### OGPのURLを作成 #####
    # @course_result 専用の「共有トークン」を作る。
    # .signed_id でトークンを作成している（Rails標準機能）
    token = @course_result.signed_id(purpose: :share_result, expires_in: 30.days)

    # 上で作った token をURLに埋め込んで、共有用URLを作る。
    @share_url = share_result_url(token: token)
  end

  private

  # 自分、もしくは同じ家族ルームの別ユーザーを @target_user にセットする。
  def set_target_user
    if params[:user_id].blank?
      @target_user = current_user
      return
    end

    # 家族ルームに属していない場合、自分のユーザーをセット。属している場合、同じルームのユーザー達をセット。
    @target_user = current_user.room.present? ? current_user.room.users.find_by!(public_id: params[:user_id]) : current_user
  end

  # コースで獲得したポイントを計算している。
  # @quiz_histories は QuizHistory の集まりなので earned_point を呼ぶことができる。
  def point_calculation
    @get_point = @course_result.earned_point_total
  end

  # @target_user の course_results を取得。さらに course テーブルと join する。
  def base_results_scope
    @target_user.course_results.joins(:course)
  end

  def set_filter_options(result)
    # ユーザーの成績の内、受けたことがあるコースを抜き出す。distinct で重複排除。
    course_ids = result.select(:course_id).distinct

    # プルダウン用。ユーザーの成績が存在するコースのみを表示する。
    @course_options = Course.where(id: course_ids).order(:id)

    # 成績が存在するカテゴリーを抜き出して、重複を排除。
    category_ids = Course.where(id: course_ids).select(:category_id).distinct

    # プルダウン用。ユーザーの成績が存在するカテゴリーのみを表示する。
    @category_options = Category.where(id: category_ids).order(:id)
  end

  def apply_filters(result)
    # 初期値を設定。
    results_scope = result

    # プルダウンで params course_id を受け取った時（コースの絞り込み検索）、 results_scope に course_id の絞り込み条件を追加。
    results_scope = results_scope.where(course_id: params[:course_id]) if params[:course_id].present?

    # プルダウンで params category_id を受け取った時（カテゴリーの絞り込み検索）、results_scope に category_id の絞り込み条件を追加。
    results_scope = results_scope.where(courses: { category_id: params[:category_id] }) if params[:category_id].present?

    results_scope
  end

  # 並び順・N+1対策・ページネーション込みの一覧を返す
  def paginated_results(result)
    result.includes(:course).order(created_at: :desc).page(params[:page]).per(5)
  end
end
