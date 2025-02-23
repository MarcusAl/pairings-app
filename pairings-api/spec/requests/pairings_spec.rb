require 'swagger_helper'

RSpec.describe 'pairings', type: :request do
  let!(:user) { create(:user) }
  let!(:item1) { create(:item, user: user) }
  let!(:item2) { create(:item, user: user) }
  let!(:pairing) { create(:pairing, user: user, item1: item1, item2: item2) }
  let!(:public_pairing) { create(:pairing, :public, user: user) }
  let!(:strong_pairing) { create(:pairing, user: user, strength: 5) }
  let!(:session) { create(:session, user: user) }
  let(:Authorization) { "Bearer #{session.signed_id}" }

  path '/pairings' do
    get('Lists pairings') do
      security [bearer_auth: []]
      
      parameter name: 'visible_to', in: :query, type: :string, required: false
      parameter name: 'by_strength', in: :query, type: :string, required: false
      parameter name: 'by_confidence', in: :query, type: :string, required: false
      parameter name: 'public_pairings', in: :query, type: :boolean, required: false
      parameter name: 'private_pairings', in: :query, type: :boolean, required: false
      
      response(200, 'successful') do
        run_test! do
          body = JSON.parse(response.body)
          expect(body.keys).to match_array(['data', 'meta'])
          expect(body['data'].length).to eq(3)
          expect(body['meta']).to include('page')
        end
      end

      response(200, 'filters by visibility') do
        let(:visible_to) { user.id }
        let!(:another_pairing) { create(:pairing) }
        
        run_test! do
          body = JSON.parse(response.body)
          expect(body['data'].count).to eq(3)
        end
      end

      response(200, 'filters by strength') do
        let(:by_strength) { '5' }
        
        run_test! do
          body = JSON.parse(response.body)
          expect(body['data'].map { |p| p['strength'] }.uniq).to eq([5])
        end
      end

      response(200, 'filters public pairings') do
        let(:public_pairings) { true }
        
        run_test! do
          body = JSON.parse(response.body)
          expect(body['data'].first['public']).to eq(true)
          expect(body['data'].count).to eq(1)
        end
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end

    post('Creates a pairing') do
      security [bearer_auth: []]
      consumes 'application/json'
      
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          item1_id: { type: :string },
          item2_id: { type: :string },
          strength: { type: :integer },
          confidence_score: { type: :number },
          public: { type: :boolean },
          pairing_notes: { type: :string }
        },
        required: ['item1_id']
      }

      response(201, 'pairing created') do
        let(:params) { { item1_id: item1.id } }

        run_test! do
          body = JSON.parse(response.body)
          expect(body['data']).to eq(item1.id)
        end
      end

      response(422, 'unprocessable entity') do
        let(:params) { { item1_id: nil } }
        run_test!
      end
    end
  end

  path '/pairings/{id}' do
    parameter name: :id, in: :path, type: :string, required: true

    get('Shows a pairing') do
      security [bearer_auth: []]
      
      response(200, 'successful') do
        let(:id) { pairing.id }

        run_test! do
          body = JSON.parse(response.body)
          expect(body['data']['id']).to eq(pairing.id)
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid_id' }
        run_test!
      end
    end

    patch('Updates a pairing') do
      security [bearer_auth: []]
      consumes 'application/json'

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          strength: { type: :integer },
          confidence_score: { type: :number },
          public: { type: :boolean },
          pairing_notes: { type: :string }
        }
      }

      let(:params) do
        {
          strength: 4,
          confidence_score: 0.8,
          public: true,
          pairing_notes: 'Updated notes'
        }
      end

      response(200, 'successful') do
        let(:id) { pairing.id }

        run_test! do
          body = JSON.parse(response.body)
          expect(body['data']['strength']).to eq(4)
          expect(body['data']['confidence_score']).to eq(0.8)
          expect(body['data']['public']).to eq(true)
          expect(body['data']['pairing_notes']).to eq('Updated notes')
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid_id' }
        run_test!
      end

      response(400, 'bad request') do
        let(:id) { pairing.id }
        let(:params) { { strength: 'invalid' } }
        run_test!
      end
    end

    delete('Deletes a pairing') do
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:id) { pairing.id }

        run_test! do
          expect(Pairing.exists?(pairing.id)).to be false
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid_id' }
        run_test!
      end
    end
  end
end
