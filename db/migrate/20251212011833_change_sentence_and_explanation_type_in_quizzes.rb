class ChangeSentenceAndExplanationTypeInQuizzes < ActiveRecord::Migration[7.2]
  def change
    change_column :quizzes, :sentence, :text, null: false
    change_column :quizzes, :explanation, :text
  end
end
