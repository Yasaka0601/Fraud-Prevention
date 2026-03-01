class RankingsController < ApplicationController
  # 未ログインでも、index は表示される。
  skip_before_action :authenticate_user!, only: :index

  def index
    # params で送られた値が、room であれば、@scope に room を代入。それ以外は all を代入。
    @scope = params[:scope] == "room" ? "room" : "all"

    # 変数base はランキング対象を決める。
    # 家族ルーム内のユーザーを取得するのか、全てのユーザーを取得するのかを決定する。
    base =
      if @scope == "room"
        if user_signed_in?
          current_user.room ? current_user.room.users : User.none
        else
          User.none
        end
      else
        User.all
      end

    # 0ポイントのユーザーは、ランキングに表示しない。
    base = base.where("total_point > 0")

    # 変数base に格納されているユーザーを DENSE_RANK() OVER で順位をつけ、@users に格納。
    # DENSE_RANK() OVER は postgresSQL の機能。
    @users =
      base
        .select("users.*, DENSE_RANK() OVER  (ORDER BY users.total_point DESC) AS point_rank")
        .order(total_point: :desc, id: :asc)
        .page(params[:page]).per(10)
  end
end
