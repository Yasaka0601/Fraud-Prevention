class UserBadge < ApplicationRecord
  ##### バリデーション #####
  validates :badge_type, :acquired_at, presence: true

  ##### アソシエーション #####
  belongs_to :user

  ##### バッジの種類 #####
  enum :badge_type, {
    white_belt:     0, # 白帯(1コースクリア)
    blue_belt:      1, # 青帯（５コースクリア）
    brown_belt:     2, # 茶帯（１０コースクリア）
    black_belt:     3, # 黒帯（１５コースクリア）
    master:         4, # 師範（全コースクリア）
    weekly_king:    5, # 頂点（１回目の１位）
    weekly_king_3:  6, # 覇者（３回目の１位）
    weekly_king_6:  7, # 鬼神（６回目の１位）
    weekly_king_10: 8, # 天下無双（１０回目の１位）
    weekly_second:  9, # 銀将（１回目の２位）
    weekly_third:   10 # 銅将（１回目の３位）
  }

  BADGE_NAMES = {
    white_belt:     "白帯",
    blue_belt:      "青帯",
    brown_belt:     "茶帯",
    black_belt:     "黒帯",
    master:         "師範",
    weekly_king:    "頂点",
    weekly_king_3:  "覇者",
    weekly_king_6:  "鬼神",
    weekly_king_10: "天下無双",
    weekly_second:  "銀将",
    weekly_third:   "銅将"
  }.freeze

  BADGE_DESCRIPTIONS = {
    white_belt:     "コースを1つ全問正解でクリア達成",
    blue_belt:      "コースを5つ全問正解でクリア達成",
    brown_belt:     "コースを10個全問正解でクリア達成",
    black_belt:     "コースを15個全問正解でクリア達成",
    master:         "全コース全問正解でクリア達成",
    weekly_king:    "週間ランキング1位を獲得",
    weekly_king_3:  "週間ランキング1位を3回獲得",
    weekly_king_6:  "週間ランキング1位を6回獲得",
    weekly_king_10: "週間ランキング1位を10回獲得",
    weekly_second:  "週間ランキング2位を獲得",
    weekly_third:   "週間ランキング3位を獲得",
  }.freeze

end
