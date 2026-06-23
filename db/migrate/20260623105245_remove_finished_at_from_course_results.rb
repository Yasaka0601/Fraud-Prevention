class RemoveFinishedAtFromCourseResults < ActiveRecord::Migration[7.2]
  def change
    remove_column :course_results, :finished_at, :datetime
  end
end
