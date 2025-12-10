class RemoveEntryWordFromRooms < ActiveRecord::Migration[7.2]
  def change
    remove_column :rooms, :entry_word, :string
  end
end
