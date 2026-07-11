class Users::PasswordsController < Devise::PasswordsController
  def create
    super { |resource| set_error_flash(resource) }
  end

  def update
    super { |resource| set_error_flash(resource) }
  end

  private

  def set_error_flash(resource)
    flash.now[:alert] = resource.errors.full_messages.join("、") if resource.errors.any?
  end
end
