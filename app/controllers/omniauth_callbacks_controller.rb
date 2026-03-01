class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    basic_action
  end

  private

  def basic_action
    auth = request.env["omniauth.auth"]
    return redirect_to(root_path, alert: "認証情報が取得できませんでした") unless auth.present?
    user = User.find_or_initialize_by(provider: auth["provider"], uid: auth["uid"])
    if user.new_record?
      email = auth.dig("info", "email").presence || "#{auth["uid"]}-#{auth["provider"]}@example.com"
      password = Devise.friendly_token[0, 20]
      user.assign_attributes(
        email: email,
        name: auth.dig("info", "name"),
        password: password,
        password_confirmation: password)
      user.save!
    end
    user.set_values(auth)
    sign_in(:user, user)
    redirect_to home_path, notice: "ログインしました"
  end

  def fake_email(uid, provider)
    "#{auth.uid}-#{auth.provider}@example.com"
  end
end
