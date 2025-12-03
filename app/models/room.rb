class Room < ApplicationRecord
  validates :name, presence: true, length: { maximum: 30 }
  validates :entry_word, presence: true, length: { minimum: 4, maximum: 20 }
  #子ユーザーは、hostになれないというバリデーション。
  validate :child_users_cannot_host

  belongs_to :host_user, class_name: 'User'

  private

  def child_users_cannot_host
    return if host_user.blank?
    return unless host_user.child?

    errors.add(:host_user, 'はホストになれません')
  end
end
