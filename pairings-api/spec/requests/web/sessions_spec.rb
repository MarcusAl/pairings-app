require 'rails_helper'

RSpec.describe 'Web::Sessions', type: :request do
  let(:user)     { create(:user) }
  let(:password) { 'Secret1*3*5*' }

  describe 'GET /web/login' do
    it 'renders the login page' do
      get web_login_path
      expect(response).to have_http_status(:ok)
    end

    it 'redirects to dashboard when already signed in' do
      sign_in(user)
      get web_login_path
      expect(response).to redirect_to(web_root_path)
    end
  end

  describe 'POST /web/login' do
    it 'signs in with valid credentials' do
      post web_login_path, params: { email: user.email, password: password }
      expect(response).to redirect_to(web_root_path)
      expect(user.sessions.count).to eq(1)
    end

    it 'rejects invalid credentials' do
      post web_login_path, params: { email: user.email, password: 'wrong' }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'DELETE /web/logout' do
    it 'signs out and redirects to login' do
      sign_in(user)
      delete web_logout_path
      expect(response).to redirect_to(web_login_path)
    end
  end
end
