require 'rails_helper'

RSpec.describe 'Favorites', type: :request do
  let(:buyer) { create(:user, :buyer) }
  let(:owner) { create(:user, :owner) }
  let(:property) { create(:property) }

  before { sign_in buyer, scope: :user }

  describe 'GET /favorites' do
    context 'when buyer is signed in' do
      let!(:favorite) { create(:favorite, user: buyer, property: property) }

      it 'returns successful response' do
        get favorites_path
        expect(response).to have_http_status(:success)
      end

      it 'displays favorite properties' do
        get favorites_path
        expect(response.body).to include(property.title)
      end
    end

    context 'when owner tries to access' do
      before { sign_in owner, scope: :user }

      it 'redirects to root' do
        get favorites_path
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when not signed in' do
      before { sign_out :user }

      it 'redirects to sign in' do
        get favorites_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /properties/:property_id/favorite' do
    context 'when buyer is signed in' do
      it 'creates a favorite' do
        expect {
          post property_favorite_path(property), 
               headers: { 'Accept' => 'application/json' }
        }.to change(Favorite, :count).by(1)
      end

      it 'returns success response' do
        post property_favorite_path(property), 
             headers: { 'Accept' => 'application/json' }
        
        expect(response).to have_http_status(:success)
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
        expect(json_response['favorited']).to be true
      end

      context 'when already favorited' do
        before { create(:favorite, user: buyer, property: property) }

        it 'does not create duplicate favorite' do
          expect {
            post property_favorite_path(property), 
                 headers: { 'Accept' => 'application/json' }
          }.not_to change(Favorite, :count)
        end

        it 'returns error response' do
          post property_favorite_path(property), 
               headers: { 'Accept' => 'application/json' }
          
          expect(response).to have_http_status(:unprocessable_content)
          
          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('error')
        end
      end
    end

    context 'when owner tries to favorite' do
      before { sign_in owner, scope: :user }

      it 'redirects to root' do
        post property_favorite_path(property)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /properties/:property_id/favorite' do
    let!(:favorite) { create(:favorite, user: buyer, property: property) }

    context 'when buyer is signed in' do
      it 'removes the favorite' do
        expect {
          delete property_favorite_path(property), 
                 headers: { 'Accept' => 'application/json' }
        }.to change(Favorite, :count).by(-1)
      end

      it 'returns success response' do
        delete property_favorite_path(property), 
               headers: { 'Accept' => 'application/json' }
        
        expect(response).to have_http_status(:success)
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
        expect(json_response['favorited']).to be false
      end

      context 'when favorite does not exist' do
        before { favorite.destroy }

        it 'returns error response' do
          delete property_favorite_path(property), 
                 headers: { 'Accept' => 'application/json' }
          
          expect(response).to have_http_status(:not_found)
          
          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('error')
        end
      end
    end
  end
end