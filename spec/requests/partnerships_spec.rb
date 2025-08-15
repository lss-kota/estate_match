require 'rails_helper'

RSpec.describe "Partnerships", type: :request do
  let(:agent) { create(:user, :agent) }
  let(:owner) { create(:user, :owner) }
  let(:partnership) { create(:partnership, agent: agent, owner: owner) }

  describe "GET /partnerships" do
    context "when signed in as agent" do
      before { sign_in agent, scope: :user }

      it "returns http success" do
        get partnerships_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in as owner" do
      before { sign_in owner, scope: :user }

      it "returns http success" do
        get partnerships_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        get partnerships_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as buyer" do
      let(:buyer) { create(:user, :buyer) }
      before { sign_in buyer, scope: :user }

      it "redirects with error" do
        get partnerships_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /partnerships/:id" do
    context "when signed in as participant" do
      before { sign_in agent, scope: :user }

      it "returns http success" do
        get partnership_path(partnership)
        expect(response).to have_http_status(:success)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        get partnership_path(partnership)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /partnerships" do
    context "when signed in as agent" do
      before { sign_in agent, scope: :user }

      it "creates partnership and redirects" do
        expect {
          post partnerships_path, params: { 
            partnership: { 
              owner_id: owner.id,
              commission_rate: 5.0 
            } 
          }
        }.to change(Partnership, :count).by(1)
        
        expect(response).to redirect_to(partnerships_path)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        post partnerships_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /partnerships/:id" do
    context "when signed in as participant" do
      before { sign_in agent, scope: :user }

      it "terminates partnership and redirects" do
        delete partnership_path(partnership)
        expect(partnership.reload.status).to eq('terminated')
        expect(response).to redirect_to(partnerships_path)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        delete partnership_path(partnership)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
