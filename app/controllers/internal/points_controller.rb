class Internal::PointsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  before_action :authenticate_internal_token!

  def weekly_reset
    WeeklyPointResetService.call
    head :ok
  end

  private

  def authenticate_internal_token!
    token = request.headers["X-Internal-Token"]
    head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(token.to_s, ENV.fetch("INTERNAL_API_TOKEN"))
  end
end
