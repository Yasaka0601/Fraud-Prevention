class CoursesController < ApplicationController
  # 未ログインでもコース選択可能にする
  skip_before_action :authenticate_user!, only: :index

  def index
    @category = Category.find(params[:category_id])
    @courses  = @category.courses
    @challenged_course_ids = []
    @conquered_course_ids = []

    if user_signed_in?
      records = current_user.user_course_challenges.where(course_id: @courses.select(:id))
      @challenged_course_ids = records.pluck(:course_id)
      @conquered_course_ids = records.where.not(conquered_at: nil).pluck(:course_id)
    end
  end
end
