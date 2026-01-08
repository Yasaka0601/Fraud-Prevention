class Users::RegistrationsController < Devise::RegistrationsController
  protected

  #サインアップ後のリダイレクト
  def after_sign_up_path_for(resource)
    home_path
  end

  # アカウント情報を編集した際、パスワードの要求を省略する。
  def update_resource(resource, params)
    resource.update_without_current_password(params)
  end

end