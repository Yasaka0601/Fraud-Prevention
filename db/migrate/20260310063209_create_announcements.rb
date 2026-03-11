class CreateAnnouncements < ActiveRecord::Migration[7.2]
  def change
    create_table :announcements do |t|
      t.string :title, null: false
      t.text :body
      t.string :url
      t.datetime :published_at

      t.timestamps
    end
  end
end
