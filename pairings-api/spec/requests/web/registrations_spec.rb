require 'rails_helper'

RSpec.describe 'Web::Registrations', type: :request do
  describe 'GET /web/signup' do
    it 'renders the signup page' do
      get web_signup_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /web/signup' do
    let(:valid_params) do
      { user: { email: 'new@example.com', password: 'Secret1*3*5*', password_confirmation: 'Secret1*3*5*' } }
    end

    it 'creates an account and signs in' do
      expect { post web_signup_path, params: valid_params }.to change(User, :count).by(1)
      expect(response).to redirect_to(web_root_path)
    end

    it 'rejects invalid registration' do
      post web_signup_path, params: { user: { email: '', password: 'short', password_confirmation: 'short' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
