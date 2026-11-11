class AddAffiliateToQuizzes < ActiveRecord::Migration[7.2]
  def change
    add_column :quizzes, :affiliate_text, :string
    add_column :quizzes, :affiliate_url, :string
  end
end
