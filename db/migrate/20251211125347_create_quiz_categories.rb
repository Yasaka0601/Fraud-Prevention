class CreateQuizCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :quiz_categories do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
