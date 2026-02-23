class Users::MypagesController < ApplicationController
  def show
    @user = current_user
  end
end
