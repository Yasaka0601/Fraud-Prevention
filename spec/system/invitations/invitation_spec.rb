require 'rails_helper'

RSpec.describe "Invitations", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:room) { FactoryBot.create(:room) }

  before do
    login_as_user(user)
    user.update!(room: room)
  end

  describe '招待文の送信' do

    it '招待文が画面上に表示されること' do
      visit new_room_invitation_path(room)
        click_button '招待文を発行してコピー'

        expect(page).to have_field('招待文') #招待リンク付きの招待文が生成されていることを期待
      textarea = find_field('招待文')
      expect(textarea.value).to include('http')
    end

    it '招待文をメール送信できること' do
      #他のテストでメールが送られている場合があるのでクリアにしている。
      before do
        ActionMailer::Base.deliveries.clear
      end

      visit new_room_invitation_path(room)
      click_button 'メールで招待'

      fill_in 'メールアドレス', with: 'test@email.com'
      expect {
        click_button 'メールを送信する'
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(page).to have_content '招待メールを送信しました' # 招待リンク付きの招待文がメール送信できることを期待。
    end
  end
end