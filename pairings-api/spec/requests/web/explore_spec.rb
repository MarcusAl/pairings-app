require 'rails_helper'

RSpec.describe 'Web::Explore', type: :request do
  describe 'GET /web/explore/items' do
    it 'renders without authentication' do
      get web_explore_items_path
      expect(response).to have_http_status(:ok)
    end

    it 'only shows public items' do
      public_item = create(:item, :public, name: 'Public Dish')
      private_item = create(:item, name: 'Private Dish')

      get web_explore_items_path

      expect(response.body).to include(public_item.name)
      expect(response.body).not_to include(private_item.name)
    end
  end

  describe 'GET /web/explore/pairings' do
    it 'renders without authentication' do
      get web_explore_pairings_path
      expect(response).to have_http_status(:ok)
    end

    it 'only shows public pairings' do
      public_pairing = create(:pairing, :public)
      create(:pairing)

      get web_explore_pairings_path

      expect(response.body).to include(public_pairing.item1.name)
    end
  end
end
