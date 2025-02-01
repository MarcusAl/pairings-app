require 'rails_helper'

RSpec.describe PairingService do
  describe '#call' do
    let(:image) { fixture_file_upload('spec/fixtures/steak.jpg', 'image/jpeg') }
    let(:blob) { ActiveStorage::Blob.create_and_upload!(io: image, filename: 'steak.jpg') }
    
    context 'with valid response', :vcr do
      it 'returns a hash with two items' do
        VCR.use_cassette('pairing_service/valid_response') do
          result = described_class.call(image_id: blob.id)
          
          expect(result[:success?]).to be true
          expect(result[:payload]).to include(:item_1, :item_2)
          
          item1 = result[:payload][:item_1]
          expect(item1).to include(
            name: be_a(String),
            description: be_a(String),
            category: be_a(String),
            subcategory: be_a(String),
            flavor_profiles: be_an(Array),
            primary_flavor: be_a(String),
            price_range: be_a(String),
            attributes: be_a(String),
            texture: be_a(String)
          )
          expect(item1[:name]).to match(/\A\S.*\S\z/)
          expect(item1[:flavor_profiles]).not_to be_empty
        end
      end
    end
    
    context 'with error responses' do
      it 'handles rate limiting errors' do
        VCR.use_cassette('pairing_service/rate_limit_error') do
          allow_any_instance_of(Anthropic::Client).to receive(:messages)
            .and_raise(Faraday::ClientError.new(nil, { status: 429, body: { error: { message: 'Too many requests' } } }))
            
          expect { described_class.call(image_id: blob.id) }
            .to raise_error(PairingService::TooManyRequestsError)
        end
      end
      
      it 'handles invalid responses' do
        VCR.use_cassette('pairing_service/invalid_response') do
          allow_any_instance_of(Anthropic::Client).to receive(:messages)
            .and_return({ 'content' => [{ 'text' => 'Invalid|Response' }] })
            
          expect { described_class.call(image_id: blob.id) }
            .to raise_error(PairingService::ParseError)
        end
      end
    end
  end
end
