require 'rails_helper'

RSpec.describe 'Web::Items', type: :request do
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }

  describe 'GET /web/items' do
    it 'redirects to login when not signed in' do
      get web_items_path
      expect(response).to redirect_to(web_login_path)
    end

    it 'renders the items index' do
      sign_in(user)
      get web_items_path
      expect(response).to have_http_status(:ok)
    end

    it 'only shows items belonging to the current user', :aggregate_failures do
      item
      other_item = create(:item)
      sign_in(user)

      get web_items_path

      expect(response.body).to include(item.name)
      expect(response.body).not_to include(other_item.name)
    end

    it 'filters by category', :aggregate_failures do
      create(:item, user: user, category: 'wine', name: 'Pinot Noir')
      create(:item, user: user, category: 'beer', name: 'Pale Ale')
      sign_in(user)

      get web_items_path, params: { by_category: ['wine'] }

      expect(response.body).to include('Pinot Noir')
      expect(response.body).not_to include('Pale Ale')
    end
  end

  describe 'GET /web/items/:id' do
    it 'renders the item detail', :aggregate_failures do
      sign_in(user)
      get web_item_path(item)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(item.name)
    end

    it 'returns 404 for another user item' do
      sign_in(user)
      get web_item_path(create(:item))
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /web/items/new' do
    it 'renders the new item form' do
      sign_in(user)
      get new_web_item_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /web/items' do
    let(:valid_params) do
      {
        item: {
          name: 'Grilled Salmon',
          category: 'main',
          price_range: '$$',
          primary_flavor_profile: 'umami',
          flavor_profiles: %w[umami smoky]
        }
      }
    end

    it 'creates an item and redirects to show', :aggregate_failures do
      sign_in(user)

      expect { post web_items_path, params: valid_params }.to change(Item, :count).by(1)

      expect(response).to redirect_to(web_item_path(Item.last))
    end

    it 're-renders the form with invalid params' do
      sign_in(user)

      post web_items_path, params: { item: { name: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /web/items/:id/edit' do
    it 'renders the edit form' do
      sign_in(user)
      get edit_web_item_path(item)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /web/items/:id' do
    it 'updates the item and redirects to show', :aggregate_failures do
      sign_in(user)

      patch web_item_path(item), params: { item: { name: 'Updated Name' } }

      expect(response).to redirect_to(web_item_path(item))
      expect(item.reload.name).to eq('Updated Name')
    end

    it 're-renders edit with invalid params' do
      sign_in(user)

      patch web_item_path(item), params: { item: { category: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /web/items/:id' do
    it 'destroys the item and redirects to index', :aggregate_failures do
      sign_in(user)
      item

      expect { delete web_item_path(item) }.to change(Item, :count).by(-1)

      expect(response).to redirect_to(web_items_path)
    end
  end
end
