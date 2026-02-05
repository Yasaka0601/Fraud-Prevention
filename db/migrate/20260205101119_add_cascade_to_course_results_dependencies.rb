class AddCascadeToCourseResultsDependencies < ActiveRecord::Migration[7.2]
  def up
    # quiz_histories -> course_results
    remove_foreign_key :quiz_histories, :course_results
    add_foreign_key :quiz_histories, :course_results, on_delete: :cascade

    # quiz_history_choices -> quiz_histories
    remove_foreign_key :quiz_history_choices, :quiz_histories
    add_foreign_key :quiz_history_choices, :quiz_histories, on_delete: :cascade
  end

  def down
    remove_foreign_key :quiz_histories, :course_results
    add_foreign_key :quiz_histories, :course_results

    remove_foreign_key :quiz_history_choices, :quiz_histories
    add_foreign_key :quiz_history_choices, :quiz_histories
  end
end
