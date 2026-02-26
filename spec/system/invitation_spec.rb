require 'rails_helper'

RSpec.describe "Invitations", type: :system do
  # 招待リンクを発行する側のユーザー/ルーム。
  let(:owner) { FactoryBot.create(:user, email: "owner_#{SecureRandom.hex(4)}@example.com") }
  let(:room) { FactoryBot.create(:room) }

  describe '招待リンクの生成' do
    before do
      # 招待リンクの生成はルーム所属中ユーザーのみ実行できる。
      login_as_user(owner)
      owner.update!(room: room)
    end

    it '招待リンクを生成して表示できること' do
      visit new_room_invitation_path(room)
      click_button '招待リンクを生成する'

      # 生成後は show 画面に遷移し、案内文とリンク入力欄が表示される。
      expect(page).to have_current_path(%r{/rooms/.*/invitations/\d+}, ignore_query: true)
      expect(page).to have_content('招待リンク')
      expect(page).to have_content('招待リンクを作成しました')

      # readonly の入力欄に join 用URLが入っていることを確認する。
      input = find('input[readonly]', match: :first)
      expect(input.value).to include("/rooms/#{room.public_id}/invitations/")
      expect(input.value).to include('/join/')
    end
  end

  describe 'アクセス制御' do
    it 'ルーム外のユーザーは招待リンク作成画面にアクセスできないこと' do
      outsider = FactoryBot.create(:user, email: "outsider_#{SecureRandom.hex(4)}@example.com")
      login_as_user(outsider)

      visit new_room_invitation_path(room)

      # 非メンバーは作成画面へ入れず、ルームホームへ戻される。
      expect(page).to have_current_path(home_rooms_path)
      expect(page).to have_content('このルームにはアクセスできません')
    end
  end

  describe '招待リンク経由の入室' do
    # DB上で有効な招待トークンを作り、join URL を組み立てる。
    let!(:invitation) do
      invite = room.invitations.build
      invite.create_invitation_digest
      invite
    end
    let(:join_path) { join_room_invitation_path(room, invitation, token: invitation.invitation_token) }

    it '未所属ユーザーが招待ルームへ入室できること' do
      guest = FactoryBot.create(:user, email: "guest_#{SecureRandom.hex(4)}@example.com")
      login_as_user(guest)

      visit join_path
      click_button '入室する（参加）'

      # 参加後はルームホームへ遷移し、所属が更新される。
      expect(page).to have_current_path(home_rooms_path)
      expect(page).to have_content("#{room.name} に参加しました")
      expect(guest.reload.room).to eq(room)
    end

    it '別ルーム所属ユーザーは確認後に切り替え入室できること' do
      guest = FactoryBot.create(:user, email: "switch_guest_#{SecureRandom.hex(4)}@example.com")
      other_room = FactoryBot.create(:room, name: '別の家族ルーム')
      guest.update!(room: other_room)
      login_as_user(guest)

      visit join_path
      click_button '入室する（参加）'

      # まずは確認アラートが表示される。
      expect(page).to have_content('本当に入室しますか？')

      click_button 'はい'

      # 確認後に切り替え参加できることを確認する。
      expect(page).to have_current_path(home_rooms_path)
      expect(page).to have_content("#{room.name} に参加しました")
      expect(guest.reload.room).to eq(room)
    end
  end
end
