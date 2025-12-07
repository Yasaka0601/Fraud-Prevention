require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション(一般ユーザー)' do # 一般ユーザーのバリデーションに関するテストを書くという宣言
    subject { build(:user, role: :general) } # FactoryBot.build(:user)の省略形。Userのインスタンスを作成している。

    it { should validate_presence_of(:name) } # name は必須項目であること。
    it { should validate_length_of(:name).is_at_most(50) } # name の長さは 50字まで。
    it { should validate_presence_of(:email) } # email は必須項目であること。
    it { should validate_uniqueness_of(:email).case_insensitive } # email はユニークであること。
  end

  describe 'バリデーション(子ユーザー)' do
    let(:child_user) { build(:user, role: :child, name: 'test_user', email: nil, password: nil, password_confirmation: nil, room_id: 1) } # let はテスト用の変数を定義するという意味。ここではchild_userというテスト用の変数を定義している。

    it 'name と room_id があれば email と password なしでも有効であること' do
      expect(child_user).to be_valid
      # be_valid は内部的に expect(child_user.valid?).to eq(true) をしている。
      # valid?メソッドは、モデルに書いた validates を全部チェックして問題がなければ true エラーがあれば false を返す。
    end
  end
end
