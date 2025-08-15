require 'rails_helper'

RSpec.describe "Inquiries", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/inquiries/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/inquiries/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/inquiries/create"
      expect(response).to have_http_status(:success)
    end
  end

end
