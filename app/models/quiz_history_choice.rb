class QuizHistoryChoice < ApplicationRecord
  ##### アソシエーション #####
  belongs_to :quiz_history
  belongs_to :choice
end
