class CreateUserCourseChallenges < ActiveRecord::Migration[7.2]
  def change
    create_table :user_course_challenges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.datetime :conquered_at
      t.timestamps
    end

    add_index :user_course_challenges, [:user_id, :course_id], unique: true
  end
end
