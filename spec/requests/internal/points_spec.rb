require 'rails_helper'

RSpec.describe "Internal::Points", type: :request do
  around do |example|
    original = ENV["INTERNAL_API_TOKEN"]
    ENV["INTERNAL_API_TOKEN"] = "correct-token"
    example.run
    ENV["INTERNAL_API_TOKEN"] = original
  end

  describe "POST /internal/points/weekly_reset" do
    context "正しいトークンが送られたとき" do
      it "200が返り、WeeklyPointResetServiceが呼ばれる" do
        expect(WeeklyPointResetService).to receive(:call)
        post "/internal/points/weekly_reset", headers: { "X-Internal-Token" => "correct-token" }
        expect(response).to have_http_status(:ok)
      end
    end

    context "トークンが間違っているとき" do
      it "401が返る" do
        post "/internal/points/weekly_reset", headers: { "X-Internal-Token" => "wrong-token" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "トークンが送られなかったとき" do
      it "401が返る" do
        post "/internal/points/weekly_reset"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
