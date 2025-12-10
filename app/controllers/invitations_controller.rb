class InvitationsController < ApplicationController

  # gem deviseのメソッドでログインしているかを確認
  before_action :authenticate_user!, only: %i[ show new create edit update ]
  # show new create edit update を実行する時、下記の set_room メソッドを実行。
  before_action :set_room, only: %i[ show new create edit update ]
  # show new create edit update を実行する時、下記の set_invitation メソッドを実行。
  before_action :set_invitation, only: %i[ show edit update ]
  # edit update を実行する時、下記の valid_user メソッドを実行。
  before_action :valid_user, only: %i[ edit update ]
  # update アクションを実行する時、下記の check_expiration メソッドを実行。
  before_action :check_expiration, only: %i[ update ]

  def show
    # @room のトークンの有効期限を @expiration_time に代入している。view で @expiration を使用する。
    @expiration_time = @invitation.expiration_time
    # フォームにトークンを表示させるための記述。:token は create から渡される。
    @token = params[:token]
  end

  # フォームを出している。
  def new; end

  def create
    # @room のトークンを生成、ハッシュ化して保存、発行時間も保存。room_model を参照。
    @invitation = @room.invitations.build
    @invitation.create_invitation_digest
    flash[:notice]= "招待リンクを作成しました"
    # URL の :id には invitation.id を使い、生トークンはクエリパラメータ token= に乗せる。
    redirect_to room_invitation_path(@room, @invitation, token: @invitation.invitation_token)
  end

  def edit; end

  def update
    # 招待されたのが子ユーザーであれば、切り替え不可。
    if current_user.child?
      flash[:danger] = '子ユーザーは招待リンクから家族ルームを切り替えできません'
      return redirect_to home_rooms_path
    end

    if current_user.room_id == @room.id
      flash[:danger] = '既にこの家族ルームに参加しています'
    else
      current_user.update!(room: @room)
      flash[:notice] = "#{@room.name} に参加しました"
    end
    redirect_to home_rooms_path
  end

  private

  # params[:room_id] と一致する room を @room に代入している。
  def set_room
    @room = Room.find(params[:room_id])
  end

  # room 経由で invitation レコードを取り出して @invitation に代入している。
  # @room.invitations はInvitation.where(room_id: @room.id) とほぼ同じイメージの 関連の集合（ActiveRecord::Relation）
  # その上で .find(params[:id]) 集合の中から「id が params[:id] のレコードを1件取ってくる」
  def set_invitation
    @invitation = @room.invitations.find(params[:id])
  end

  # @room の招待トークンの期限を確認している。
  # 期限切れなら「招待リンクが期限切れです」とフラッシュメッセージが表示され、ルートページへ遷移する。
  def check_expiration
    if @invitation.invitation_expired?
      flash[:danger] = "招待リンクが期限切れです"
      redirect_to root_path
    end
  end

  # @room が存在している AND @room のトークンと params[:id] が一致している。
  # 正しくない( unless が true)なら、ルートページへ遷移する。
  def valid_user
    unless @invitation && @invitation.authenticated?(params[:token])
      flash[:danger] = '招待リンクが無効です'
      redirect_to root_path
    end
  end
end
