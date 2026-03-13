class CreateUserBadges < ActiveRecord::Migration[7.2]
  def change
    create_table :user_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :badge_type, null: false
      t.datetime :acquired_at, null: false
      t.timestamps
    end
  end
end
