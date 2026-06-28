class RemoveAcquiredAtFromUserBadges < ActiveRecord::Migration[7.2]
  def change
    remove_column :user_badges, :acquired_at, :datetime
  end
end
