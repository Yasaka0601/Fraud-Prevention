class Users::RegistrationsController < Devise::RegistrationsController
  include Devise::Controllers::Rememberable
  include ImageProcessable

  PROFILE_IMAGE_MAX_WIDTH = 400

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

  def update_resource(resource, params)
    # ImageProcessableモジュールを使って、画像処理をする。
    if params[:image].present?
      params[:image] = process_and_transform_image(params[:image], PROFILE_IMAGE_MAX_WIDTH)
    end
    # アカウント情報を編集した際、パスワードの要求を省略する。
    resource.update_without_current_password(params)

    # 画像処理のエラー
    rescue ImageProcessable::ImageProcessingError
      resource.errors.add(:image, "画像の処理に失敗しました。別の画像でお試しください。")
    false
  end
end
