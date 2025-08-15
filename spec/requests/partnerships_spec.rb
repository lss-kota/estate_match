require 'rails_helper'

RSpec.describe "Partnerships", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/partnerships/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/partnerships/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/partnerships/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/partnerships/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
