class ShareResultsController < ApplicationController
  # 共有ページは未ログインでも見られるようにする
  skip_before_action :authenticate_user!, only: :show
  before_action :set_course_result_from_token

  def show
    category_name = @course_result.course.category.name
    course_name   = @course_result.course.name
    total         = @course_result.total_questions
    correct       = @course_result.correct_count

    # 動的OGP（テキストのみ） optionsに入る値。
    helpers.assign_meta_tags(
      title: "「#{category_name}」「#{course_name}」コース",
      description: "#{total}問中、#{correct}問正解。",
      url: request.original_url
    )
  end

  private

  # 共有URLに含まれる token から、対応する成績データを取り出すメソッド
  def set_course_result_from_token
    @course_result = CourseResult.includes(course: :category)
                                 .find_signed(params[:token], purpose: :share_result)
    return if @course_result.present?

    render_expired_page
  end

  def render_expired_page
    helpers.assign_meta_tags(
      title: "共有リンクの有効期限が切れました",
      description: "共有された成績リンクは有効期限切れ、または無効です。",
      url: request.original_url
    )
    render :expired, status: :gone
  end
end
