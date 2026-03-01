require 'rails_helper'

RSpec.describe "Rankings", type: :system do
  describe '道場全体ランキング' do
    # 全体ランキングの表示順と 0pt 除外を確認するためのユーザー。
    let!(:first_user) { create(:user, name: '全体1位ユーザー', email: "rank_all_1_#{SecureRandom.hex(4)}@example.com", total_point: 30) }
    let!(:second_user) { create(:user, name: '全体2位ユーザー', email: "rank_all_2_#{SecureRandom.hex(4)}@example.com", total_point: 20) }
    let!(:zero_user) { create(:user, name: '全体圏外ユーザー', email: "rank_all_0_#{SecureRandom.hex(4)}@example.com", total_point: 0) }

    it 'ポイント順に表示され、0pt のユーザーは表示されないこと' do
      visit rankings_path(scope: "all")

      # 全体ランキングに必要な最小表示だけ確認する。
      expect(page).to have_content('週間番付')
      expect(page).to have_content(first_user.name)
      expect(page).to have_content(second_user.name)
      expect(page).not_to have_content(zero_user.name)

      # 画面上で高得点ユーザーが先に表示されていることを確認する。
      ranking_text = page.text
      expect(ranking_text.index(first_user.name)).to be < ranking_text.index(second_user.name)
    end
  end

  describe '家族ルームランキング' do
    let!(:room) { create(:room) }
    # ログインユーザーと同じルームのメンバーだけを表示対象にする。
    let!(:current_user) { create(:user, name: 'ルーム1位ユーザー', email: "rank_room_1_#{SecureRandom.hex(4)}@example.com", room: room, total_point: 20) }
    let!(:room_member) { create(:user, name: 'ルーム2位ユーザー', email: "rank_room_2_#{SecureRandom.hex(4)}@example.com", room: room, total_point: 10) }
    let!(:outside_user) { create(:user, name: 'ルーム外ユーザー', email: "rank_room_out_#{SecureRandom.hex(4)}@example.com", total_point: 100) }

    before do
      # room スコープはログイン状態が前提のため、先に認証する。
      login_as_user(current_user)
    end

    it '同じ家族ルームのユーザーだけがポイント順に表示されること' do
      visit rankings_path(scope: "room")

      # 同じルームのユーザーは表示され、ルーム外ユーザーは表示されないことを確認する。
      expect(page).to have_content(current_user.name)
      expect(page).to have_content(room_member.name)
      expect(page).not_to have_content(outside_user.name)

      # ルーム内でも高得点順で並んでいれば十分。
      ranking_text = page.text
      expect(ranking_text.index(current_user.name)).to be < ranking_text.index(room_member.name)
    end
  end
end
