require 'rails_helper'

RSpec.describe UserBadge, type: :model do
  describe 'バリデーション' do
    it 'badge_type がなければ無効である' do
      badge = build(:user_badge, badge_type: nil)
      expect(badge).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    it { is_expected.to belong_to(:user) }
  end

  describe '定数' do
    # BADGE_NAMES と BADGE_DESCRIPTIONS が全バッジタイプを網羅しているか確認する。
    # UserBadge.badge_types は enum で定義されたキー一覧を返す。
    it 'BADGE_NAMES が全バッジタイプを網羅している' do
      expect(UserBadge::BADGE_NAMES.keys).to match_array(UserBadge.badge_types.keys.map(&:to_sym))
    end

    it 'BADGE_DESCRIPTIONS が全バッジタイプを網羅している' do
      expect(UserBadge::BADGE_DESCRIPTIONS.keys).to match_array(UserBadge.badge_types.keys.map(&:to_sym))
    end
  end
end
