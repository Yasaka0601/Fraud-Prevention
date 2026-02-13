class CoursesController < ApplicationController
  # 未ログインでもコース選択可能にする
  skip_before_action :authenticate_user!, only: :index

  def index
    @category = Category.find(params[:category_id])
    @courses  = @category.courses
  end
end