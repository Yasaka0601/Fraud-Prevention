class TopsController < ApplicationController
  # top アクションだけは、ログインしてなくてもアクセスできる。
  skip_before_action :authenticate_user!, only: :top

  def top
    redirect_to home_path if user_signed_in?
  end
end
