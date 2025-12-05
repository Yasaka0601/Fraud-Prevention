class AddRoomIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :room, foreign_key: true
  end
end
