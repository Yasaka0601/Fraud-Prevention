class LegalController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :terms, :privacy ]

  # 利用規約
  def terms;end

  # プライバシーポリシー
  def privacy;end
end
