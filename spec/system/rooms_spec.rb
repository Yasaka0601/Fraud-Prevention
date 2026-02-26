require 'rails_helper'

RSpec.describe "Rooms", type: :system do
  # ルーム機能の system spec で共通利用するユーザー/ルーム。
  let(:user) { FactoryBot.create(:user) }
  let(:room) { FactoryBot.create(:room) }

  before do
    # ルーム関連画面はログイン必須なので、毎回先にログインする。
    login_as_user(user)
  end

  describe '家族ルームの作成' do
    context '正常な入力の場合' do
      it '家族ルームが作成出来ること' do
        visit new_room_path

        expect {
          # 必須項目を埋めて作成し、レコード作成を確認する。
          fill_in '家族ルーム名', with: 'test_room'
          click_button '作成する'
        }.to change(Room, :count).by(1)

        # 作成成功時はルームホームに戻る。
        expect(page).to have_current_path(home_rooms_path)
        expect(page).to have_content '家族ルームを作成しました'
      end
    end

    context '異常な入力の場合' do
      it '家族ルームを作成出来ない' do
        visit new_room_path

        expect {
          # 名前未入力のまま送信し、作成されないことを確認する。
          click_button '作成する'
        }.not_to change(Room, :count)

        expect(page).to have_content('家族ルーム名を入力してください')
      end
    end
  end

  describe '家族ルームの編集機能' do
    before do
      # 編集・退室は「所属中ルーム」が前提のため、先に参加状態を作る。
      user.update!(room: room)
    end

    it '家族ルームを編集できること' do
      visit edit_room_path(room)

      # 入力更新後にフラッシュとDB更新の両方を確認する。
      fill_in '家族ルーム名', with: 'test_room_change'
      click_button '変更を保存する'

      # 更新成功時はルームホームに戻る。
      expect(page).to have_current_path(home_rooms_path)
      expect(page).to have_content('家族ルームを更新しました')

      # DBの中身が本当に変わったか確認
      room.reload
      expect(room.name).to eq 'test_room_change'
    end

    it '家族ルームから退室できること' do
      visit edit_room_path(room)

      # 退室は2段階確認のため、最初のクリックで確認UIが出ることを確認する。
      click_button 'この家族ルームから退室する'
      expect(page).to have_content('本当に退室しますか？')

      expect {
        # 確認後に実行し、最後の1人ならルーム自体が削除されることを確認する。
        click_button 'はい、退室します'
      }.to change(Room, :count).by(-1)

      # 退室完了後はルームホームへ戻る。
      expect(page).to have_current_path(home_rooms_path)
      expect(page).to have_content('家族ルームを退出しました')
      expect(user.reload.room).to be_nil
    end
  end
end
