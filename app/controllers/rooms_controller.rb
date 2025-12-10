class RoomsController < ApplicationController
  before_action :set_have_room, only: %i[edit update destroy]

  def home; end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      flash[:notice] = "家族ルームを作成しました"
      current_user.update!(room_id: @room.id)
      redirect_to home_rooms_path
    else
      flash.now[:danger] = "家族ルームを作成出来ませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def edit;end

  def update
    if @room.update(room_params)
      flash[:notice] = "家族ルームを更新しました"
      redirect_to home_rooms_path
    else
      flash.now[:danger] = "家族ルームを更新出来ませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @room.destroy!
    flash[:notice] = "家族ルームを削除しました"
    redirect_to home_rooms_path
  end

  private

  def room_params
    params.require(:room).permit(:name)
  end

  def set_have_room
    @room = current_user.room
    if @room.nil?
      flash[:danger] = "どの家族ルームにも参加していません"
      redirect_to home_rooms_path
      return
    end

    unless @room.id == params[:id].to_i
      flash[:danger] = "参加している家族ルームではありません"
      redirect_to home_rooms_path
      return
    end
  end
end
