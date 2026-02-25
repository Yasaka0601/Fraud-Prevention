class AddColumnRooms < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    add_column :rooms, :public_id, :uuid, default: -> { "gen_random_uuid()" }, null: false
    add_index :rooms, :public_id, unique: true
  end
end
