class ApplicationController < ActionController::Base
  #ログインしているかをチェックするコールバック
  before_action :authenticate_user!

  # Deviseのコントローラーであれば、configure_permitted_parametersメソッドを呼び出すというコールバック。
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  # Devise 版の Strong Parameters。 email と password はデフォルトで設定されている。
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
