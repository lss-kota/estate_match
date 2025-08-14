require 'rails_helper'

RSpec.describe "Legal pages", type: :request do
  describe "GET /terms" do
    it "returns http success" do
      get "/terms"
      expect(response).to have_http_status(200)
    end

    it "contains the terms title" do
      get "/terms"
      expect(response.body).to include("利用規約")
    end

    it "contains the main content" do
      get "/terms"
      expect(response.body).to include("本規約")
      expect(response.body).to include("利用登録")
      expect(response.body).to include("禁止事項")
    end
  end

  describe "GET /privacy" do
    it "returns http success" do
      get "/privacy"
      expect(response).to have_http_status(200)
    end

    it "contains the privacy policy title" do
      get "/privacy"
      expect(response.body).to include("プライバシーポリシー")
    end

    it "contains the main content" do
      get "/privacy"
      expect(response.body).to include("個人情報")
      expect(response.body).to include("取得する情報")
      expect(response.body).to include("利用目的")
    end
  end

  describe "GET /company" do
    it "returns http success" do
      get "/company"
      expect(response).to have_http_status(200)
    end

    it "contains the company information title" do
      get "/company"
      expect(response.body).to include("運営会社情報")
    end

    it "contains company details" do
      get "/company"
      expect(response.body).to include("株式会社EstateMatch")
      expect(response.body).to include("会社概要")
      expect(response.body).to include("事業内容")
    end
  end

  describe "GET /tokutei" do
    it "returns http success" do
      get "/tokutei"
      expect(response).to have_http_status(200)
    end

    it "contains the tokutei title" do
      get "/tokutei"
      expect(response.body).to include("特定商取引法に基づく表示")
    end

    it "contains required information" do
      get "/tokutei"
      expect(response.body).to include("販売業者")
      expect(response.body).to include("株式会社EstateMatch")
      expect(response.body).to include("無料")
    end
  end
end