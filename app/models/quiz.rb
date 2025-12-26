class Quiz < ApplicationRecord

  ##### Active Storage #####
  has_one_attached :image

  ##### バリデーション #####
  validates :name, presence: true, length: { maximum: 50 }
  validates :sentence, presence: true

  # 画像ファイルの種類とサイズのバリデーション
  ACCEPTED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  validates :image, content_type: ACCEPTED_CONTENT_TYPES,
                    size: { less_than_or_equal_to: 5.megabytes }

  ##### アソシエーション #####
  has_many :choices, dependent: :destroy

  has_many :course_quizzes, dependent: :destroy
  has_many :courses, through: :course_quizzes

  has_many :quiz_categories, dependent: :destroy
  has_many :categories, through: :quiz_categories
end
