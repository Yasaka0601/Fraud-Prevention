class HomesController < ApplicationController
  skip_before_action :authenticate_user!, only: :top
  def top; end

  def home; end
end
