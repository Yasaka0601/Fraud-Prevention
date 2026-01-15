class HomesController < ApplicationController
  def home
    @categories = Category.all
    @room = current_user.room
  end
end
