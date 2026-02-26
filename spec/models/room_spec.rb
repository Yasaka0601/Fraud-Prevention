require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'バリデーション' do
    # Roomモデルの入力制約（必須・文字数上限）を担保する。
    subject(:room) { build(:room) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(20) }
  end

  describe 'アソシエーション' do
    # ルームと関連モデルの関連定義を担保する。
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:invitations).dependent(:destroy) }
  end

  describe '#to_param' do
    # URLパラメータが public_id になる仕様を担保する。
    it 'public_id を返すこと' do
      room = create(:room)
      expect(room.to_param).to eq(room.public_id)
    end
  end
end
