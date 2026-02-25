class AddColumnUsers < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    add_column :users, :public_id, :uuid, default: -> { "gen_random_uuid()" }, null: false
    add_index :users, :public_id, unique: true
  end
end
