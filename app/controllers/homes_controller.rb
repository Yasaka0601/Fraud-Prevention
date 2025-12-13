class HomesController < ApplicationController
  def home
    @categories = Category.all
  end
end
