require 'rails_helper'

RSpec.describe 'Web::Dashboard', type: :request do
  let(:user) { create(:user) }

  describe 'GET /web' do
    it 'redirects to login when not signed in' do
      get web_root_path
      expect(response).to redirect_to(web_login_path)
    end

    it 'renders the dashboard when signed in' do
      sign_in(user)
      get web_root_path
      expect(response).to have_http_status(:ok)
    end

    it 'displays recent items and pairings' do
      item = create(:item, user: user)
      create(:pairing, user: user, item1: item, item2: create(:item, user: user))
      sign_in(user)

      get web_root_path

      expect(response.body).to include(item.name)
    end
  end
end
