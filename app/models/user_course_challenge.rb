class UserCourseChallenge < ApplicationRecord
  ##### アソシエーション #####
  belongs_to :user
  belongs_to :course
end