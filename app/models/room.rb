class Room < ApplicationRecord
  validates :name, presence: true, length: { maximum: 20 }
  validates :entry_word, presence: true, length: { minimum: 4, maximum: 20 }

  has_many :users, dependent: :nullify
end
