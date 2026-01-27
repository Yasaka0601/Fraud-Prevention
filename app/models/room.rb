class Room < ApplicationRecord

  ##### バリデーション #####
  validates :name, presence: true, length: { maximum: 20 }

  ##### アソシエーション #####
  has_many :users
  has_many :invitations, dependent: :destroy

end
