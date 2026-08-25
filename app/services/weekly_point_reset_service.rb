class WeeklyPointResetService
  def self.call
    new.call
  end

  def call
    top_users = User.order(total_point: :desc).limit(3)

    top_users.each_with_index do |user, index|
      case index
      when 0 then user.increment!(:weekly_ranking_first_count)
      when 1 then user.increment!(:weekly_ranking_second_count)
      when 2 then user.increment!(:weekly_ranking_third_count)
      end
      BadgeGrantService.new(user).grant_ranking_badges
    end

    reset_count = User.update_all(total_point: 0)
    Rails.logger.info "Reset points for #{reset_count} users"
  end
end
