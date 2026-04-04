require 'rails_helper'

RSpec.describe 'Web::Pairings', type: :request do
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }

  describe 'GET /web/pairings' do
    it 'redirects to login when not signed in' do
      get web_pairings_path
      expect(response).to redirect_to(web_login_path)
    end

    it 'renders the pairings index' do
      sign_in(user)
      get web_pairings_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /web/pairings/:id' do
    it 'renders the pairing detail' do
      pairing = create(:pairing, user: user, item1: item, item2: create(:item, user: user))
      sign_in(user)

      get web_pairing_path(pairing)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(pairing.item1.name)
      expect(response.body).to include(pairing.item2.name)
    end
  end

  describe 'GET /web/pairings/new' do
    it 'renders the item selector' do
      item
      sign_in(user)

      get new_web_pairing_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(item.name)
    end
  end

  describe 'POST /web/pairings' do
    it 'enqueues a pairing job and redirects' do
      sign_in(user)

      expect { post web_pairings_path, params: { item1_id: item.id } }
        .to have_enqueued_job(PairingJob)

      expect(response).to redirect_to(web_pairings_path)
    end
  end

  describe 'DELETE /web/pairings/:id' do
    it 'destroys the pairing and redirects to index' do
      pairing = create(:pairing, user: user, item1: item, item2: create(:item, user: user))
      sign_in(user)

      expect { delete web_pairing_path(pairing) }.to change(Pairing, :count).by(-1)

      expect(response).to redirect_to(web_pairings_path)
    end
  end
end
