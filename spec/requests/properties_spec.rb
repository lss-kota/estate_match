require 'rails_helper'

RSpec.describe 'Properties', type: :request do
  let(:owner) { create(:user, :owner) }
  let(:buyer) { create(:user, :buyer) }
  let(:property) { create(:property, user: owner) }

  describe 'GET /properties' do
    let!(:properties) { create_list(:property, 3) }

    it 'returns successful response' do
      get properties_path
      expect(response).to have_http_status(:success)
    end

    it 'displays all active properties' do
      get properties_path
      properties.each do |property|
        expect(response.body).to include(property.title)
      end
    end

    it 'does not display draft properties' do
      draft_property = create(:property, :draft)
      get properties_path
      expect(response.body).not_to include(draft_property.title)
    end
  end

  describe 'GET /properties/:id' do
    it 'returns successful response' do
      get property_path(property)
      expect(response).to have_http_status(:success)
    end

    it 'displays property details' do
      get property_path(property)
      expect(response.body).to include(property.title)
      expect(response.body).to include(property.description)
    end
  end

  describe 'GET /properties/new' do
    context 'when owner is signed in' do
      before { sign_in owner, scope: :user }

      it 'returns successful response' do
        get new_property_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when buyer tries to access' do
      before { sign_in buyer, scope: :user }

      it 'redirects to root' do
        get new_property_path
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when not signed in' do
      it 'redirects to sign in' do
        get new_property_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /properties' do
    let(:property_params) do
      {
        property: {
          title: '新しい物件',
          description: '素晴らしい物件です',
          property_type: 'house',
          prefecture: '東京都',
          city: '渋谷区',
          address: '1-1-1',
          sale_price: 5000,
          status: 'active'
        }
      }
    end

    context 'when owner is signed in' do
      before { sign_in owner, scope: :user }

      context 'with valid parameters' do
        it 'creates a new property' do
          expect {
            post properties_path, params: property_params
          }.to change(Property, :count).by(1)
        end

        it 'redirects to property show page' do
          post properties_path, params: property_params
          expect(response).to redirect_to(property_path(Property.last))
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            property: {
              title: '',
              property_type: '',
              prefecture: '',
              city: '',
              status: ''
            }
          }
        end

        it 'does not create a property' do
          expect {
            post properties_path, params: invalid_params
          }.not_to change(Property, :count)
        end

        it 'renders new template' do
          post properties_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context 'when buyer tries to create' do
      before { sign_in buyer, scope: :user }

      it 'redirects to root' do
        post properties_path, params: property_params
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /properties/:id' do
    let(:update_params) do
      {
        property: {
          title: '更新された物件',
          description: '更新された説明'
        }
      }
    end

    context 'when property owner is signed in' do
      before { sign_in owner, scope: :user }

      it 'updates the property' do
        patch property_path(property), params: update_params
        property.reload
        expect(property.title).to eq('更新された物件')
        expect(property.description).to eq('更新された説明')
      end

      it 'redirects to property show page' do
        patch property_path(property), params: update_params
        expect(response).to redirect_to(property_path(property))
      end
    end

    context 'when different user tries to update' do
      let(:other_owner) { create(:user, :owner) }
      before { sign_in other_owner, scope: :user }

      it 'redirects to root' do
        patch property_path(property), params: update_params
        expect(response).to redirect_to(root_path)
      end

      it 'does not update the property' do
        original_title = property.title
        patch property_path(property), params: update_params
        property.reload
        expect(property.title).to eq(original_title)
      end
    end
  end

  describe 'DELETE /properties/:id' do
    context 'when property owner is signed in' do
      before { sign_in owner, scope: :user }

      it 'deletes the property' do
        property # create the property
        expect {
          delete property_path(property)
        }.to change(Property, :count).by(-1)
      end

      it 'redirects to my properties page' do
        delete property_path(property)
        expect(response).to redirect_to(my_properties_path)
      end
    end

    context 'when different user tries to delete' do
      let(:other_owner) { create(:user, :owner) }
      before { sign_in other_owner, scope: :user }

      it 'redirects to root' do
        delete property_path(property)
        expect(response).to redirect_to(root_path)
      end

      it 'does not delete the property' do
        property # create the property
        expect {
          delete property_path(property)
        }.not_to change(Property, :count)
      end
    end
  end
end