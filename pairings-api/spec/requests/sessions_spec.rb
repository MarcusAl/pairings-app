require 'swagger_helper'

RSpec.describe 'sessions', type: :request do
  let!(:user) { create(:user) }
  let(:expired_session) { create(:session, :expired, user: user) }

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

        run_test! do
          body = JSON.parse(response.body)
          expect(body['data']['id']).to eq(Session.last.id)
          expect(Session.last.expires_at).to be_within(1.second).of(Session::DEFAULT_EXPIRATION.from_now)
          expect(body['data']['user_id']).to eq(user.id)
        end
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
        let!(:other_session)   { create(:session, user: user) }
        let!(:current_session) { create(:session, user: user) }
        let(:Authorization)    { "Bearer #{current_session.signed_id}" }

        run_test! do
          expect(Session.exists?(current_session.id)).to be false
          expect(Session.exists?(other_session.id)).to be true
          expect(user.sessions.active.count).to eq(1)
        end
      end

      response(401, 'unauthorized with expired session') do
        let(:Authorization) { "Bearer #{expired_session.signed_id}" }

        run_test!
      end

      response(401, 'unauthorized with invalid token') do
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
        let!(:active_session) { create(:session, user: user) }
        let(:Authorization) { "Bearer #{active_session.signed_id}" }

        run_test! do
          sessions = JSON.parse(response.body)['data']
          expect(sessions.length).to eq(1)
          expect(sessions.first['id']).to eq(active_session.id)
        end
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  path '/sessions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    let!(:session) { create(:session, user: user) }
    let!(:Authorization) { "Bearer #{session.signed_id}" }

    get('Shows a session') do
      consumes 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:id) { session.id }

        run_test! do
          body = JSON.parse(response.body)
          expect(body['data']).to include('expires_at')
          expect(body['data']['id']).to eq(session.id)
          expect(body['data']['user_id']).to eq(user.id)
        end
      end
    end

    delete('Destroys a session') do
      consumes 'application/json'
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:id) { session.id }

        run_test!
      end

      response(401, 'unauthorized with expired session') do
        let(:id) { expired_session.id }
        let(:Authorization) { "Bearer #{expired_session.signed_id}" }

        run_test!
      end
    end
  end
end
