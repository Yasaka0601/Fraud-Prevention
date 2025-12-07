class RemoveHostUserIdFromRooms < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :rooms, column: :host_user_id
    remove_index :rooms, :host_user_id
    remove_column :rooms, :host_user_id, :bigint
  end
end
