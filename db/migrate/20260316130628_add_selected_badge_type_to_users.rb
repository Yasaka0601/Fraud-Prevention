class AddSelectedBadgeTypeToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :selected_badge_type, :integer
  end
end
