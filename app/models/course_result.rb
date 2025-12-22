class CourseResult < ApplicationRecord
  ##### アソシエーション #####
  belongs_to :user
  belongs_to :course

  has_many :quiz_histories, dependent: :destroy
end
