class Users::SessionsController < Devise::SessionsController
  protected

  # ログイン後のリダイレクト
  def after_sign_in_path_for(resource)
    home_path
  end

end
