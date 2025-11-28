class Users::RegistrationsController < Devise::RegistrationsController
  protected

  #サインアップ後のリダイレクト
  def after_sign_up_path_for(resource)
    home_path
  end

end