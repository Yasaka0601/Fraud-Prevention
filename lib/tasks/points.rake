namespace :points do
  desc "毎週月曜日にユーザーのポイントをリセットする"
  task weekly_reset: :environment do
    # 上位３位のユーザーを total_point の降順で取得
    top_users = User.order(total_point: :desc).limit(3)

    # 上位３人のユーザーにカウントを加算し、バッジを付与
    top_users.each_with_index do |user, index|
      # カウント加算
      case index
      when 0 then user.increment!(:weekly_ranking_first_count)
      when 1 then user.increment!(:weekly_ranking_second_count)
      when 2 then user.increment!(:weekly_ranking_third_count)
      end
      # バッジ付与
      BadgeGrantService.new(user).grant_ranking_badges
    end

    # 全ユーザーのポイントをリセット
    reset_count = User.update_all(total_point: 0)
    Rails.logger.info "Reset points for #{reset_count} users"
  end
end
