require 'swagger_helper'

RSpec.describe 'items', type: :request do
  let!(:user) { create(:user) }
  let!(:item) { create(:item, :with_image, user: user) }
  let!(:public_item) { create(:item, :public, :with_image, user: user) }
  let!(:drink_item) { create(:item, :drink, :with_image, user: user) }
  let!(:session) { create(:session, user: user) }
  let(:Authorization) { "Bearer #{session.signed_id}" }

  path '/items' do
    get('Lists items') do
      security [bearer_auth: []]
      
      parameter name: 'by_category[category]', in: :query, type: :string, required: false
      parameter name: 'by_flavor_profile[flavor_profile]', in: :query, type: :string, required: false
      parameter name: 'search[query]', in: :query, type: :string, required: false
      parameter name: 'visible_to[user_id]', in: :query, type: :string, required: false
      
      response(200, 'successful') do
        run_test! do
          body = JSON.parse(response.body)
          expect(body.keys).to match_array(['data', 'meta'])
          expect(body['data'].length).to eq(3)
          expect(body['meta']).to include('page')
        end
      end

      response(200, 'filters by category') do
        let(:'by_category[category]') { 'drink' }
        
        run_test! do
          body = JSON.parse(response.body)
          expect(body['data'].map { |i| i['category'] }.uniq).to eq(['drink'])
        end
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end

    post('Creates an item') do
      security [bearer_auth: []]
      consumes 'multipart/form-data'

      parameter name: :name, in: :formData, type: :string, required: true
      parameter name: :description, in: :formData, type: :text
      parameter name: :image, in: :formData, type: :file, required: true
      parameter name: :category, in: :formData, type: :string, enum: Item::CATEGORIES.keys
      parameter name: :flavor_profiles, in: :formData, type: :array
      parameter name: :primary_flavor_profile, in: :formData, type: :string
      parameter name: :price_range, in: :formData, type: :string, enum: Item::PRICE_RANGES.keys
      parameter name: :public, in: :formData, type: :boolean

      let(:description) { Faker::Food.description }
      let(:category) { Item::CATEGORIES.keys.first }
      let(:price_range) { Item::PRICE_RANGES.keys.first }
      let(:image) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg') }
      let(:flavor_profiles) { ['sweet', 'salty'] }
      let(:primary_flavor_profile) { 'sweet' }
      let(:public) { false }
      
      response(201, 'item created') do
        let(:name) { Faker::Food.dish }

        run_test! do
          body = JSON.parse(response.body)
          expect(body['data']['name']).to eq(name)
          expect(body['data']['category']).to eq(category)
          expect(body['data']['price_range']).to eq(price_range)
          expect(body['data']['flavor_profiles']).to match_array(flavor_profiles)
          expect(body['data']['image_url']).to be_present
        end
      end

      response(400, 'bad request') do
        let(:name) { '' }

        run_test!
      end
    end
  end

  path '/items/{id}' do
    parameter name: :id, in: :path, type: :string, required: true

    get('Shows an item') do
      security [bearer_auth: []]
      
      response(200, 'successful') do
        let(:id) { item.id }

        run_test! do
          body = JSON.parse(response.body)
          expect(body['data']['id']).to eq(item.id)
          expect(body['data']['name']).to eq(item.name)
          expect(body['data']['image_url']).to be_present
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid_id' }
        run_test!
      end
    end

    patch('Updates an item') do
      security [bearer_auth: []]
      consumes 'multipart/form-data'

      parameter name: :name, in: :formData, type: :string
      parameter name: :category, in: :formData, type: :string, enum: Item::CATEGORIES.keys
      parameter name: :description, in: :formData, type: :string
      parameter name: :public, in: :formData, type: :boolean

      let(:name) { 'Updated Name' }
      let(:category) { Item::CATEGORIES.keys.last }
      let(:description) { 'Updated Description' }
      let(:public) { true }

      response(200, 'successful') do
        let(:id) { item.id }

        run_test! do
          body = JSON.parse(response.body)
          expect(body['data']['name']).to eq('Updated Name')
          expect(body['data']['category']).to eq(category)
          expect(body['data']['description']).to eq(description)
          expect(body['data']['public']).to eq(public)
          expect(body['data']['image_url']).to be_present
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid_id' }

        run_test!
      end

      response(400, 'bad request') do
        let(:id) { item.id }
        let(:name) { '' }

        run_test!
      end
    end

    delete('Deletes an item') do
      security [bearer_auth: []]

      response(200, 'successful') do
        let(:id) { item.id }

        run_test! do
          expect(Item.exists?(item.id)).to be false
        end
      end

      response(404, 'not found') do
        let(:id) { 'invalid_id' }
        run_test!
      end
    end
  end
end
