class CreateCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :courses do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :max_questions, null: false

      t.timestamps
    end
  end
end
