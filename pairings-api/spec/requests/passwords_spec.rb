require 'swagger_helper'

RSpec.describe 'passwords', type: :request do
  before do
    @user = create(:user, :random_email)
  end

  path '/password' do
    patch('Updates password') do
      security [bearer_auth: []]
      consumes 'application/json'
      
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          password: { type: :string },
          password_confirmation: { type: :string },
          password_challenge: { type: :string }
        },
        required: [:password, :password_confirmation]
      }

      response(200, 'password updated') do
        let(:session) { Session.create!(user: @user) }
        let(:Authorization) { "Bearer #{session.signed_id}" }
        let(:params) do
          {
            password: 'NewSecret1*3*5*',
            password_confirmation: 'NewSecret1*3*5*',
            password_challenge: 'Secret1*3*5*'
          }
        end

        run_test! do |response|
          expect(response.status).to eq(200)
          @user.reload
          expect(@user.authenticate('NewSecret1*3*5*')).to be_truthy
        end
      end

      response(422, 'invalid parameters') do
        let(:session) { Session.create!(user: @user) }
        let(:Authorization) { "Bearer #{session.signed_id}" }

        context 'when passwords do not match' do
          let(:params) do
            {
              password: 'NewSecret1*3*5*',
              password_confirmation: 'DifferentPassword1*',
              password_challenge: 'Secret1*3*5*'
            }
          end

          run_test!
        end

        context 'when password is too short' do
          let(:params) do
            {
              password: 'short',
              password_confirmation: 'short',
              password_challenge: 'Secret1*3*5*'
            }
          end

          run_test!
        end

        context 'when current password is incorrect' do
          let(:params) do
            {
              password: 'NewSecret1*3*5*',
              password_confirmation: 'NewSecret1*3*5*',
              password_challenge: 'WrongPassword1*'
            }
          end

          run_test!
        end
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:params) do
          {
            password: 'NewSecret1*3*5*',
            password_confirmation: 'NewSecret1*3*5*'
          }
        end
        
        run_test!
      end
    end
  end
end
