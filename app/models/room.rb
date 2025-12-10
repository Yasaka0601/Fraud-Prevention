class Room < ApplicationRecord

  ##### コールバック #####
  # Room が destroy される「直前」に、紐づくユーザーを処理する。
  before_destroy :room_destroy_on_users

  ##### バリデーション #####
  validates :name, presence: true, length: { maximum: 20 }

  ##### アソシエーション #####
  has_many :users
  has_many :invitations, dependent: :destroy

  private

  #####　ルーム削除時、子ユーザーも一緒に削除。一般ユーザーは退室される #####
  def room_destroy_on_users
    # 子ユーザーは、room と共に削除される。
    users.child.each do |child_user|
      child_user.destroy!
    end

    # 一般ユーザーは、room_id を nil にする。
    users.general.update_all(room_id: nil)
  end
end
