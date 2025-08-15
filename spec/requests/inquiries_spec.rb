require 'rails_helper'

RSpec.describe "Inquiries", type: :request do
  let(:agent) { create(:user, :agent) }
  let(:buyer) { create(:user, :buyer) }
  let(:property) { create(:property) }
  let(:inquiry) { create(:inquiry, buyer: buyer, agent: agent, property: property) }

  describe "GET /inquiries" do
    context "when signed in as agent" do
      before { sign_in agent, scope: :user }

      it "returns http success" do
        get inquiries_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        get inquiries_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /inquiries/:id" do
    context "when signed in as agent" do
      before { sign_in agent, scope: :user }

      it "returns http success" do
        get inquiry_path(inquiry)
        expect(response).to have_http_status(:success)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        get inquiry_path(inquiry)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /inquiries" do
    context "when signed in as buyer" do
      before { sign_in buyer, scope: :user }

      it "creates inquiry and redirects" do
        expect {
          post inquiries_path, params: { 
            inquiry: { 
              property_id: property.id,
              agent_id: agent.id,
              message: "この物件について相談したいです"
            } 
          }
        }.to change(Inquiry, :count).by(1)
        
        expect(response).to redirect_to(property)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        post inquiries_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
