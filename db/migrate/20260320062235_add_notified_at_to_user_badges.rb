class AddNotifiedAtToUserBadges < ActiveRecord::Migration[7.2]
  def change
    add_column :user_badges, :notified_at, :datetime
  end
end
