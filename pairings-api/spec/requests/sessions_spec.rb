require 'swagger_helper'

RSpec.describe 'sessions', type: :request do
  let!(:user) { create(:user) }

  path '/sign_in' do
    post('Creates a session') do
      consumes 'application/json'

      parameter name: :params,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    email: { type: :string },
                    password: { type: :string }
                  },
                  required: %i[email password]
                }

      response(201, 'session created') do
        let(:params) { { email: user.email, password: 'Secret1*3*5*' } }

        run_test!
      end

      response(401, 'unauthorized') do
        let(:params) { { email: 'wrong@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end

  path '/sign_out' do
    delete('Destroys current session') do
      security [bearer_auth: []]

      response(200, 'successful') do
        let!(:other_session)   { Session.create!(user: user) }
        let!(:current_session) { Session.create!(user: user) }
        let(:Authorization)    { "Bearer #{current_session.signed_id}" }

        run_test! do
          expect(Session.exists?(current_session.id)).to be false
          expect(Session.exists?(other_session.id)).to be true
          expect(user.sessions.count).to eq(1)
        end
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  path '/sessions' do
    get('Lists all sessions') do
      consumes 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:session)       { Session.create!(user: user) }
        let(:Authorization) { "Bearer #{session.signed_id}" }

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  path '/sessions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    let!(:session)       { Session.create!(user: user) }
    let!(:Authorization) { "Bearer #{session.signed_id}" }

    get('Shows a session') do
      consumes 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:id) { session.id }

        run_test!
      end
    end

    delete('Destroys a session') do
      consumes 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:id) { session.id }

        run_test!
      end
    end
  end
end
