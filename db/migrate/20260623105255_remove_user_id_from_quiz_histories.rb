class RemoveUserIdFromQuizHistories < ActiveRecord::Migration[7.2]
  def change
    remove_column :quiz_histories, :user_id, :bigint
  end
end
