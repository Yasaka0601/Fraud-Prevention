class Choice < ApplicationRecord

  ##### バリデーション #####
  validates :quiz_id, presence: true
  validates :text, presence: true
  validates :is_correct, inclusion: { in: [true, false] }

  ##### アソシエーション #####
  belongs_to :quiz
  has_many :quiz_history_choices, dependent: :destroy
  has_many :quiz_histories, through: :quiz_history_choices
end
