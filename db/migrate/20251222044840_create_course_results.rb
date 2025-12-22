class CreateCourseResults < ActiveRecord::Migration[7.2]
  def change
    create_table :course_results do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :correct_count,   null: false, default: 0
      t.integer :total_questions, null: false, default: 0
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
