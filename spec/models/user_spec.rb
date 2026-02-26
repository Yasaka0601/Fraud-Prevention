require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    # Userモデルの入力制約（name/email）を担保する。
    subject(:user) { build(:user, role: :general) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'アソシエーション' do
    # ユーザーはルーム未所属を許可しつつ、関連レコードの従属削除を行う。
    it { is_expected.to belong_to(:room).optional }
    it { is_expected.to have_many(:course_results).dependent(:destroy) }
    it { is_expected.to have_many(:user_course_challenges).dependent(:destroy) }
  end

end
