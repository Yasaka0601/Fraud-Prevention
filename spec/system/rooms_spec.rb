require 'rails_helper'

RSpec.describe "Rooms", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:room) { FactoryBot.create(:room) }

  before do
    login_as_user(user)
  end

  describe '家族ルームの作成' do
    context '正常な入力の場合' do
      it '家族ルームが作成出来ること' do
        visit new_room_path

        expect {
          fill_in '家族ルーム名', with: 'test_room'
          fill_in '合言葉', with: 'テストの合言葉'
          click_button '作成'
        }.to change(Room, :count).by(1)

        expect(page).to have_content '家族ルームを作成しました'
      end
    end

    context '異常な入力の場合' do
      it '家族ルームを作成出来ない' do
        visit new_room_path

        expect {
          click_button '作成'
        }.not_to change(Room, :count)

        expect(page).to have_content('家族ルーム名を入力してください')
        expect(page).to have_content('合言葉を入力してください')
      end
    end
  end

  describe '家族ルームの編集機能' do

    before do
      # FactoryBot で作成したユーザーが room に参加している状態を作る。
      user.update!(room: room)
    end

    it '家族ルームを削除できること' do
      visit edit_room_path(room)

      expect {
        click_button 'この家族ルームを削除'
      }.to change(Room, :count).by(-1)

      expect(page).to have_content('家族ルームを削除しました')
    end

    it '家族ルームを編集できること' do
      visit edit_room_path(room)

        fill_in '家族ルーム名', with: 'test_room_change'
        fill_in '合言葉', with: 'テストの合言葉変更'
        click_button '更新'

        expect(page).to have_content('家族ルームを更新しました')

        # DBの中身が本当に変わったか確認
        room.reload
        expect(room.name).to eq 'test_room_change'
        expect(room.entry_word).to eq 'テストの合言葉変更'
    end
  end
end

# let(:user) { FactoryBot.create(:user) }
# let(:room) { FactoryBot.create(:room, host_user: user) }
# この2行の組み合わせで、DBには User が1人作られ Room が1つ作られる
# その Room の host_user_id には、その user.id が入る
