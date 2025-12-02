require 'rails_helper'

RSpec.describe 'パスワードリセット', type: :system do
  let(:user) { FactoryBot.create(:user) }

  describe 'パスワードの変更' do
    it 'パスワードが変更できる' do
      visit new_user_password_path
      fill_in 'メールアドレス', with: user.email
      click_button '再設定メール送信'
      expect(page).to have_content('パスワードリセット手順を送信しました')

      user.reload
      visit edit_user_password_path(reset_password_token: user.reset_password_token)
      fill_in 'パスワード(6文字以上)', with: '123456789'
      fill_in 'パスワード(入力確認)', with: '123456789'
      click_button '更新'
      expect(page).to have_current_path(new_user_session_path, ignore_query: true), 'パスワードリセット後にログイン画面に遷移していません'
      expect(page).to have_content('パスワードを変更しました'), 'フラッシュメッセージ「パスワードを変更しました」が表示されていません'
    end
  end
end