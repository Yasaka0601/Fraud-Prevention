require 'rails_helper'

RSpec.describe WeeklyPointResetService do
  let!(:first_user)  { create(:user, email: "reset_1_#{SecureRandom.hex(4)}@example.com", total_point: 300) }
  let!(:second_user) { create(:user, email: "reset_2_#{SecureRandom.hex(4)}@example.com", total_point: 200) }
  let!(:third_user)  { create(:user, email: "reset_3_#{SecureRandom.hex(4)}@example.com", total_point: 100) }

  describe '.call' do
    it '全ユーザーの total_point が 0 にリセットされる' do
      WeeklyPointResetService.call
      expect([ first_user, second_user, third_user ].map { |u| u.reload.total_point }).to all(eq(0))
    end

    it '1位のユーザーの weekly_ranking_first_count が加算される' do
      expect { WeeklyPointResetService.call }.to change { first_user.reload.weekly_ranking_first_count }.by(1)
    end

    it '2位のユーザーの weekly_ranking_second_count が加算される' do
      expect { WeeklyPointResetService.call }.to change { second_user.reload.weekly_ranking_second_count }.by(1)
    end

    it '3位のユーザーの weekly_ranking_third_count が加算される' do
      expect { WeeklyPointResetService.call }.to change { third_user.reload.weekly_ranking_third_count }.by(1)
    end

    it '1位のユーザーに weekly_king バッジが付与される' do
      WeeklyPointResetService.call
      expect(first_user.user_badges.where(badge_type: :weekly_king)).to exist
    end
  end
end
