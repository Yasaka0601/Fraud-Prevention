class GuestController < ApplicationController
  skip_before_action :authenticate_user!, only: :show

  def show
    render "guests/show"
  end
end
