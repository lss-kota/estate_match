require 'rails_helper'

RSpec.describe "Admin::Partnerships", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/partnerships/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/partnerships/show"
      expect(response).to have_http_status(:success)
    end
  end

end
