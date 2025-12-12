class CreateCourseQuizzes < ActiveRecord::Migration[7.2]
  def change
    create_table :course_quizzes do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :question_number, null: false

      t.timestamps
    end
  end
end
