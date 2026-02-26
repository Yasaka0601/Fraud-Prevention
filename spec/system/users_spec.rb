require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe 'ユーザー新規登録' do
    context '正常な入力の場合' do
      it 'ユーザーの新規登録が出来ること' do
        visit new_user_registration_path
        # 登録フォームの必須入力を埋める。
        fill_in '名前', with: 'test_user'
        fill_in 'メールアドレス', with: 'example@email.com'
        fill_in 'パスワード(6文字以上)', with: 'password'
        fill_in 'パスワード(入力確認)', with: 'password'

        # このブロックで「ボタンを押した結果、Userの件数が1件増えること」を確認している
        expect {
          click_button '登録'
        }.to change(User, :count).by(1)

        # サインアップ後の遷移先が home_path であることを確認する。
        expect(page).to have_current_path(home_path)
        # ログイン後ヘッダーに表示されるサービス名が見えることも合わせて確認する。
        expect(page).to have_content '詐欺対策道場'
      end
    end

    context '異常な入力の場合' do
      it 'ユーザーの新規登録が出来ない' do
        visit new_user_registration_path

        # 何も入力せずに送信し、バリデーションエラー表示を確認する。
        click_button '登録'

        expect(page).to have_content('名前を入力してください')
        expect(page).to have_content('メールアドレスを入力してください')
        expect(page).to have_content('パスワードを入力してください')
        # 現行 Devise の挙動では、未入力時は confirmation ではなく password 本体のみエラーになる。
        expect(page).not_to have_content('パスワード(入力確認)を入力してください')
      end
    end
  end

  describe 'ログイン' do
    # ログイン対象の既存ユーザーを事前作成する。
    let!(:user) { FactoryBot.create(:user) }

    context '正常な入力の場合' do
      it 'ログインできること' do
        visit new_user_session_path
        fill_in 'メールアドレス', with: 'example@email.com'
        # ログイン画面の現在のラベルに合わせて入力する。
        fill_in 'パスワード(6文字以上)', with: 'password'
        click_button 'ログイン'
        # ログイン成功時は home_path に遷移する。
        expect(page).to have_current_path(home_path)
        expect(page).to have_content 'ログインしました'
      end
    end

    context '異常な入力の場合' do
      it 'エラーメッセージが表示されること' do
        visit new_user_session_path
        fill_in 'メールアドレス', with: 'example@email.com'
        fill_in 'パスワード(6文字以上)', with: 'non_password'
        click_button 'ログイン'
        expect(page).to have_content 'メールアドレスまたはパスワードが違います。'
      end
    end
  end
end
