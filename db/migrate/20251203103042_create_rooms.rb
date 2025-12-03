class CreateRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :rooms do |t|
      t.string  :name, null: false
      t.string :entry_word, null: false
      t.references :host_user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

  end
end