class RankingsController < ApplicationController
  def index
    @scope = params[:scope] == "room" ? "room" : "all"

    base =
      if @scope == "room"
        current_user.room ? current_user.room.users : User.none
      else
        User.all
      end

    ranked =
      base
        .select("users.*, DENSE_RANK() OVER  (ORDER BY users.total_point DESC) AS point_rank")
        .order(total_point: :desc, id: :asc)

    @users = ranked.page(params[:page]).per(10)
    points = @users.map(&:total_point).uniq
    @tie_counts =
    points.empty? ? {} : base.where(total_point: points).group(:total_point).count
  end
end