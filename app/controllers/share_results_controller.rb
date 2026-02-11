class ShareResultsController < ApplicationController
  # 共有ページは未ログインでも見られるようにする
  skip_before_action :authenticate_user!, only: :show
  before_action :set_course_result_from_token

  def show
    category_name = @course_result.course.category.name
    course_name   = @course_result.course.name
    total         = @course_result.total_questions
    correct       = @course_result.correct_count

    # 動的OGP（テキストのみ）
    helpers.assign_meta_tags(
      title: "「#{category_name}」「#{course_name}」コース",
      description: "#{total}問中、#{correct}問正解。",
      url: request.original_url
    )
  end

  private

  def set_course_result_from_token
    @course_result = CourseResult.includes(course: :category)
                                  .find_signed!(params[:token], purpose: :share_result)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end
end
