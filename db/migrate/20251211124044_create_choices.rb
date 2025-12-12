class CreateChoices < ActiveRecord::Migration[7.2]
  def change
    create_table :choices do |t|
      t.references :quiz, null: false, foreign_key: true
      t.string :text, null: false
      t.boolean :is_correct, null: false, default: false

      t.timestamps
    end
  end
end
