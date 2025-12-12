class CreateQuizzes < ActiveRecord::Migration[7.2]
  def change
    create_table :quizzes do |t|
      t.string :name, null: false
      t.string :sentence, null: false
      t.string :explanation
      t.integer :give_point

      t.timestamps
    end
  end
end
