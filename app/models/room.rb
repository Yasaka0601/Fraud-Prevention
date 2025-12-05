class Room < ApplicationRecord
  validates :host_user_id, presence: true
  validates :name, presence: true, length: { maximum: 20 }
  validates :entry_word, presence: true, length: { minimum: 4, maximum: 20 }
  #子ユーザーは、hostになれないというバリデーション。
  validate :child_users_cannot_host

  has_many :users, dependent: :nullify
  belongs_to :host_user, class_name: 'User'

  private

  def child_users_cannot_host
    return if host_user.blank?
    return unless host_user.child?

    errors.add(:host_user, 'はホストになれません')
  end
end
