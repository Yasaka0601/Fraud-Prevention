class AddWeeklyRankingFirstCountUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :weekly_ranking_first_count, :integer, default: 0, null: false
    add_column :users, :weekly_ranking_second_count, :integer, default: 0, null: false
    add_column :users, :weekly_ranking_third_count, :integer, default: 0, null: false
  end
end
