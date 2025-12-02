require 'rails_helper'

RSpec.describe 'パスワードリセット', type: :system do
  let(:user) { FactoryBot.create(:user) }

  describe 'パスワードの変更' do
    it 'パスワードが変更できる' do
      visit new_user_password_path
      fill_in 'メールアドレス', with: user.email
      click_button '再設定メール送信'
      expect(page).to have_content('パスワードの再設定について数分以内にメールでご連絡いたします')

      # 生のトークンを発行してもらう（戻り値が「メールに載るRAWトークン」）
      raw_token = user.send_reset_password_instructions
      # それをそのままURLパラメータに使う
      visit edit_user_password_path(reset_password_token: raw_token)
      fill_in '新しいパスワード(6文字以上)', with: '123456789'
      fill_in '新しいパスワード(入力確認)', with: '123456789'
      click_button 'パスワードを変更'
      expect(page).to have_content('パスワードが正しく変更されました。')
    end
  end
end