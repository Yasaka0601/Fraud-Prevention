require "rails_helper"

RSpec.describe "ShareResults", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, email: "share_results_spec@example.com") }
  let(:category) { Category.create!(name: "防犯カテゴリ") }
  let(:course) { Course.create!(category: category, name: "テストコース", max_questions: 10) }
  let(:course_result) do
    CourseResult.create!(
      user: user,
      course: course,
      correct_count: 3,
      total_questions: 5,
      finished_at: Time.current
    )
  end

  describe "GET /share/results/:token" do
    it "有効なトークンなら共有成績画面を表示する" do
      token = course_result.signed_id(purpose: :share_result, expires_in: 30.days)

      get share_result_path(token: token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("テストコース")
    end

    it "無効なトークンなら失効画面を表示する" do
      get share_result_path(token: "invalid-token")

      expect(response).to have_http_status(:gone)
      expect(response.body).to include("共有リンクの有効期限が切れました")
    end

    it "期限切れトークンなら失効画面を表示する" do
      token = nil

      travel_to Time.zone.local(2026, 2, 11, 10, 0, 0) do
        token = course_result.signed_id(purpose: :share_result, expires_in: 1.second)
      end

      travel_to Time.zone.local(2026, 2, 11, 10, 0, 2) do
        get share_result_path(token: token)
      end

      expect(response).to have_http_status(:gone)
      expect(response.body).to include("共有リンクの有効期限が切れました")
    end
  end
end
