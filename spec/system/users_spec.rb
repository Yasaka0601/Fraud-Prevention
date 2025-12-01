require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe 'ユーザー新規登録' do
    context '正常な入力の場合' do
      it 'ユーザーの新規登録が出来ること' do
        visit new_user_registration_path
        fill_in '名前', with: 'test_user'
        fill_in 'メールアドレス', with: 'example@email.com'
        fill_in 'パスワード(６文字以上)', with: 'password'
        fill_in 'パスワード(入力確認)', with: 'password'

        # このブロックで「ボタンを押した結果、Userの件数が1件増えること」を確認している
        expect {
          click_button '登録'
        }.to change(User, :count).by(1)

        # 遷移先に '詐欺対策道場ホーム' という文言があると確認。
        expect(page).to have_content '詐欺対策道場ホーム'
      end
    end

    context '異常な入力の場合' do
      it 'ユーザーの新規登録が出来ない' do
        visit new_user_registration_path

        # 何も入力せずに登録ボタンをクリック
        click_button '登録'

        #エラーメッセージの確認
          expect(page).to have_content('名前を入力してください')
          expect(page).to have_content('メールアドレスを入力してください')
          expect(page).to have_content('パスワードを入力してください')
          expect(page).to have_content('パスワード（入力確認）を入力してください')
      end
    end
  end

  describe 'ログイン' do
    let!(:user) { create(:user, role: :general, name: 'test_user', email: 'example@email.com', password: 'password', password_confirmation: 'password') }

    context '正常な入力の場合' do
      it 'ログインできること' do
        visit new_user_session_path
        fill_in 'メールアドレス', with: 'example@email.com'
        fill_in 'パスワード', with: 'password'
        click_button 'ログイン'
        expect(page).to have_content 'ログインしました'
      end
    end

    context '異常な入力の場合' do
      it 'エラーメッセージが表示されること' do
        visit new_user_session_path
        fill_in 'メールアドレス', with: 'example@email.com'
        fill_in 'パスワード', with: 'non_password'
        click_button 'ログイン'
        expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
      end
    end
  end
end
