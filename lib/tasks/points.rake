namespace :points do
  desc "毎週月曜日にユーザーのポイントをリセットする"
  task weekly_reset: :environment do
    reset_count = User.update_all(total_point: 0)
    Rails.logger.info "Reset points for #{reset_count} users"
  end
end
