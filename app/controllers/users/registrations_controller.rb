class Users::RegistrationsController < Devise::RegistrationsController
  include Devise::Controllers::Rememberable
  protected

  # サインアップ後、remember_me を適用させる（ログイン状態保持）
  def sign_up(resource_name, resource)
    super
    remember_me(resource) if resource.persisted?
  end

  # サインアップ後のリダイレクト先
  def after_sign_up_path_for(resource)
    home_path
  end

  # アカウント情報を編集した際、パスワードの要求を省略する。
  def update_resource(resource, params)
    resource.update_without_current_password(params)
  end

end