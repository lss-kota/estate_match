require 'rails_helper'

RSpec.describe "Agent Registration", type: :request do
  let(:membership_plan) { create(:membership_plan) }
  
  describe "POST /users" do
    context "when registering as an agent" do
      let(:agent_params) do
        {
          user: {
            name: "山田太郎",
            email: "agent@example.com",
            password: "password123",
            password_confirmation: "password123",
            user_type: "agent",
            company_name: "山田不動産株式会社",
            license_number: "東京都知事(1)第12345号",
            membership_plan_id: membership_plan.id
          }
        }
      end

      it "creates a new agent user successfully" do
        expect {
          post user_registration_path, params: agent_params
        }.to change(User, :count).by(1)
        
        user = User.last
        expect(user.agent?).to be true
        expect(user.company_name).to eq("山田不動産株式会社")
        expect(user.license_number).to eq("東京都知事(1)第12345号")
        expect(user.membership_plan).to eq(membership_plan)
      end

      it "redirects to dashboard with welcome message" do
        post user_registration_path, params: agent_params
        
        expect(response).to redirect_to(dashboard_path)
        follow_redirect!
        
        expect(flash[:notice]).to include("不動産業者として登録が完了しました")
        expect(flash[:notice]).to include("山田不動産株式会社")
        expect(flash[:notice]).to include("東京都知事(1)第12345号")
      end

      context "when required agent fields are missing" do
        it "fails validation without company_name" do
          agent_params[:user][:company_name] = ""
          
          expect {
            post user_registration_path, params: agent_params
          }.not_to change(User, :count)
        end

        it "fails validation without license_number" do
          agent_params[:user][:license_number] = ""
          
          expect {
            post user_registration_path, params: agent_params
          }.not_to change(User, :count)
        end

        it "fails validation without membership_plan" do
          agent_params[:user][:membership_plan_id] = ""
          
          expect {
            post user_registration_path, params: agent_params
          }.not_to change(User, :count)
        end
      end
    end

    context "when registering as buyer or owner" do
      let(:buyer_params) do
        {
          user: {
            name: "佐藤花子",
            email: "buyer@example.com",
            password: "password123",
            password_confirmation: "password123",
            user_type: "buyer"
          }
        }
      end

      it "creates buyer without agent-specific fields" do
        expect {
          post user_registration_path, params: buyer_params
        }.to change(User, :count).by(1)
        
        user = User.last
        expect(user.buyer?).to be true
        expect(user.company_name).to be_nil
        expect(user.license_number).to be_nil
        expect(user.membership_plan).to be_nil
      end

      it "uses standard redirect for non-agent users" do
        post user_registration_path, params: buyer_params
        
        expect(response).to redirect_to(dashboard_path)
        follow_redirect!
        
        expect(flash[:notice]).not_to include("不動産業者として登録が完了しました")
      end
    end
  end

  describe "GET /users/sign_up" do
    it "displays the registration form with agent option" do
      get new_user_registration_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include("不動産業者として登録")
      expect(response.body).to include("会社名")
      expect(response.body).to include("宅地建物取引業免許番号")
      expect(response.body).to include("会員プラン")
    end

    it "includes JavaScript for dynamic field toggling" do
      get new_user_registration_path
      
      expect(response.body).to include("toggleAgentFields")
      expect(response.body).to include("agent-fields")
    end

    it "shows membership plan comparison" do
      create(:membership_plan, name: "ベーシックプラン", monthly_property_limit: 10)
      create(:membership_plan, name: "プレミアムプラン", monthly_property_limit: 30)
      
      get new_user_registration_path
      
      expect(response.body).to include("会員プラン比較")
      expect(response.body).to include("ベーシックプラン")
      expect(response.body).to include("プレミアムプラン")
    end
  end
end