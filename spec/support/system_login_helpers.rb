# ログインの処理をモジュール化。( ChatGPT作 )
module SystemLoginHelpers
  def login_as_user(user)
    visit new_user_session_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード(6文字以上)', with: 'password'
    click_button 'ログイン'
  end
end