class Users::UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  # 未通知バッジを通知する
  before_action :notify_new_badges, only: :show, if: -> { user_signed_in? && current_user.public_id == params[:public_id] }

  def show
    @user = User.find_by!(public_id: params[:public_id])
    @badges = @user.user_badges.order(:badge_type)
    @conquered_count = @user.user_course_challenges.where.not(conquered_at: nil).count
  end

  private

  # 未通知バッジを通知するメソッド
  def notify_new_badges
    # 未通知のバッジを un_notified に格納
    un_notified = current_user.user_badges.where(notified_at: nil)

    if un_notified.present?
      flash.now[:new_badges] = un_notified.map(&:badge_type)
      un_notified.update_all(notified_at: Time.current)
    end
  end
end
