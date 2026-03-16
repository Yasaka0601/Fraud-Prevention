class Users::UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show

  def show
    @user = User.find_by!(public_id: params[:public_id])
    @badges = @user.user_badges.order(:badge_type)
    @conquered_count = @user.user_course_challenges.where.not(conquered_at: nil).count
  end
end
