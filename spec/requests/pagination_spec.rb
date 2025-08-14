require 'rails_helper'

RSpec.describe "Pagination", type: :request do
  let(:owner) { create(:user, :owner) }
  
  before do
    # 15件の物件を作成（1ページ12件なので2ページになる）
    15.times do |i|
      create(:property, 
        title: "テスト物件#{i + 1}",
        user: owner,
        status: :active
      )
    end
  end

  describe "GET /properties" do
    it "returns successful response for first page" do
      get properties_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("件の物件")
    end

    it "returns successful response for second page" do
      get properties_path(page: 2)
      expect(response).to have_http_status(200)
      expect(response.body).to include("件の物件")
    end

    it "shows pagination links when there are multiple pages" do
      get properties_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("次へ")
    end

    it "handles search parameter correctly" do
      get properties_path(search: "テスト")
      expect(response).to have_http_status(200)
      expect(response.body).to include("件の物件")
    end

    it "does not show pagination when there are few properties" do
      # 既存の物件をすべて削除
      Property.destroy_all
      
      # 5件だけ作成
      5.times do |i|
        create(:property, title: "少数物件#{i + 1}", user: owner, status: :active)
      end
      
      get properties_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("件の物件")
      expect(response.body).not_to include("次へ")
      expect(response.body).not_to include("前へ")
    end
  end
end