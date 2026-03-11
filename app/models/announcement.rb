class Announcement < ApplicationRecord
  ##### バリデーション #####
  validates :title, presence: true

  ##### スコープ #####
  scope :published, -> { where("published_at <= ?", Time.current).order(published_at: :desc) }
end
