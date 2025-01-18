require 'swagger_helper'

RSpec.describe 'registrations', type: :request do
  path '/sign_up' do
    post('Creates a user') do
      consumes 'application/json'

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: [:email, :password]
      }

      response(201, 'user created') do
        let(:params) { { email: 'test@example.com', password: 'Secret1*3*5*' } }
        run_test!
      end
    end
  end
end

