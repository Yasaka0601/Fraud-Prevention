class HomesController < ApplicationController
  # 未ログインでも、ホームは表示される。
  skip_before_action :authenticate_user!, only: :home

  def home
    @categories = Category.all

    # 未ログインであれば、@room は nil
    @room = user_signed_in? ? current_user.room : nil

    # お知らせを取得
    @announcements = Announcement.published.limit(3)
  end
end
