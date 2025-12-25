class RankingsController < ApplicationController
  def index
    @scope = params[:scope] == "room" ? "room" : "all"

    base =
      if @scope == "room"
        current_user.room ? current_user.room.users : User.none
      else
        User.all
      end

    @users = base.order(total_point: :desc, id: :asc)
  end
end