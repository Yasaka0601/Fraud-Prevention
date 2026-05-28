class ApplicationController < ActionController::Base
  # 古いURLにアクセスされたら、新しいURLへリダイレクトする。
  before_action :redirect_to_custom_domain
  # ログインしているかをチェックするコールバック
  before_action :authenticate_user!
  # Deviseのコントローラーであれば、configure_permitted_parametersメソッドを呼び出すというコールバック。
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  # 新しいURLへリダイレクトさせるメソッド
  def redirect_to_custom_domain
    if Rails.env.production? && request.host != "sagi-taisaku.com"
      redirect_to "https://sagi-taisaku.com#{request.path}", status: :moved_permanently
    end
  end

  # Devise 版の Strong Parameters。 email と password はデフォルトで設定されている。
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :image ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :image ])
  end
end
