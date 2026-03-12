class RemoveStartedAtFromCourseResults < ActiveRecord::Migration[7.2]
  def change
    remove_column :course_results, :started_at, :datetime
  end
end
