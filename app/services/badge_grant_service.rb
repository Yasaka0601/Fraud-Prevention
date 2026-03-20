class BadgeGrantService
  # コース攻略バッジ条件の定数（降順に並べる）
  COURSE_BADGES = [
    { badge_type: :master,     threshold: -> { Course.count } }, # 全コース。 -> { } で包むことで実行を後まわしにできる( Proc )
    { badge_type: :black_belt, threshold: 15 },
    { badge_type: :brown_belt, threshold: 10 },
    { badge_type: :blue_belt,  threshold: 5 },
    { badge_type: :white_belt, threshold: 1 }
  ].freeze # .freeze で配列の変更を禁止（凍結）

  # 週間1位バッジ条件の定数（降順に並べる）
  FIRST_RANKING_BADGES = [
    { badge_type: :weekly_king_10, threshold: 10 },
    { badge_type: :weekly_king_6,  threshold: 6 },
    { badge_type: :weekly_king_3,  threshold: 3 },
    { badge_type: :weekly_king,    threshold: 1 }
  ].freeze

  def initialize(user)
    @user = user
  end

  # コースクリア時に呼び出す
  def grant_course_badges
    # ユーザーのコースクリア回数
    conquered_count = @user.user_course_challenges.where.not(conquered_at: nil).count

    # 新規取得バッジの空配列を作成
    newly_granted = []

    COURSE_BADGES.each do |badge|
      # .is_a?(Proc) で threshold が Proc (後で実行する処理の塊。ここでは Course.count ) なのか判定。
      # Proc であれば .call で Course.count を実行する。
      threshold = badge[:threshold].is_a?(Proc) ? badge[:threshold].call : badge[:threshold]
      if conquered_count >= threshold
        result = grant_badge(badge[:badge_type], notified: true)
        newly_granted << result if result
      end
    end
    # 戻り値
    newly_granted
  end

  # rakeタスクの週次バッチ処理で呼び出すメソッド
  def grant_ranking_badges
    grant_first_ranking_badges
    grant_badge(:weekly_second) if @user.weekly_ranking_second_count == 1
    grant_badge(:weekly_third)  if @user.weekly_ranking_third_count == 1
  end

  private

  # 週間ランキング１位の回数を評価し、バッジを与えるメソッド
  def grant_first_ranking_badges
    count = @user.weekly_ranking_first_count
    FIRST_RANKING_BADGES.each do |badge|
      if count >= badge[:threshold]
        grant_badge(badge[:badge_type])
      end
    end
  end

  def grant_badge(badge_type, notified: false)
    # ユーザーの badge_type が一致するバッジが DB に存在するなら return する。
    return if @user.user_badges.where(badge_type: badge_type).exists?
    # @user の user_badges レコードを作成。
    @user.user_badges.create!(
      badge_type: badge_type,
      acquired_at: Time.current,
      notified_at: notified ? Time.current : nil
      )
  end
end
