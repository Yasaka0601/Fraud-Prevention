require 'rails_helper'

RSpec.describe BadgeGrantService do
  let(:user)     { create(:user, email: "badge_#{SecureRandom.hex(4)}@example.com") }
  let(:category) { Category.create!(name: 'バッジテスト用カテゴリ') }

  # コースを1つ作り、ユーザーがクリアした記録を作成するヘルパー。
  def create_conquered_challenge(course_name: 'テストコース')
    course = Course.create!(category: category, name: course_name, max_questions: 1)
    UserCourseChallenge.create!(user: user, course: course, conquered_at: Time.current)
  end

  describe '#grant_course_badges' do
    context '1コースをクリアしたとき' do
      before { create_conquered_challenge }

      it 'white_belt バッジが付与される' do
        BadgeGrantService.new(user).grant_course_badges
        expect(user.user_badges.where(badge_type: :white_belt)).to exist
      end

      it '付与されたバッジに notified_at が設定される' do
        BadgeGrantService.new(user).grant_course_badges
        badge = user.user_badges.find_by(badge_type: :white_belt)
        expect(badge.notified_at).to be_present
      end
    end

    context 'すでに white_belt バッジを持っているとき' do
      before do
        create_conquered_challenge
        BadgeGrantService.new(user).grant_course_badges
      end

      it 'white_belt バッジが重複して付与されない' do
        expect {
          BadgeGrantService.new(user).grant_course_badges
        }.not_to change { user.user_badges.where(badge_type: :white_belt).count }
      end
    end

    context '全コースをクリアしたとき' do
      before do
        # Course.count（全コース数）と同数のコースをすべてクリアする。
        3.times { |i| create_conquered_challenge(course_name: "コース#{i + 1}") }
      end

      it 'master バッジが付与される' do
        BadgeGrantService.new(user).grant_course_badges
        expect(user.user_badges.where(badge_type: :master)).to exist
      end
    end
  end
end
