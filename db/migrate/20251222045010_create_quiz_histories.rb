class CreateQuizHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :quiz_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course_result, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true

      t.timestamps
    end
  end
end
