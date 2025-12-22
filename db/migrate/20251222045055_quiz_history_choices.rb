class QuizHistoryChoices < ActiveRecord::Migration[7.2]
  def change
    create_table :quiz_history_choices do |t|
      t.references :quiz_history, null: false, foreign_key: true
      t.references :choice,       null: false, foreign_key: true

      t.timestamps
    end
  end
end
