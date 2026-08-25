namespace :points do
  desc "毎週月曜日にユーザーのポイントをリセットする"
  task weekly_reset: :environment do
    WeeklyPointResetService.call
  end
end
