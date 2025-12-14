class RemoveQuestionNumberFromCourseQuizzes < ActiveRecord::Migration[7.2]
  def change
    remove_column :course_quizzes, :question_number, :integer
  end
end
