require 'rails_helper'

RSpec.describe PairingService do
  describe '#call' do
    let(:image) { fixture_file_upload('spec/fixtures/steak.jpg', 'image/jpeg') }
    let(:blob) { ActiveStorage::Blob.create_and_upload!(io: image, filename: 'steak.jpg') }
    
    context 'with valid response' do
      it 'returns a successful pairing', vcr: { cassette_name: 'pairing_service/valid_response' } do
        result = described_class.call(image_id: blob.id)
        
        aggregate_failures do
          expect(result[:success?]).to be true
          expect(result[:payload]).to match(
            item_1: {
              name: match(/\A\S.*\S\z/),
              description: be_present,
              category: be_present,
              subcategory: be_present,
              flavor_profiles: array_including(be_present),
              primary_flavor: be_present,
              price_range: match(/\$+/),
              attributes: be_present,
              texture: be_present
            },
            item_2: {
              name: match(/\A\S.*\S\z/),
              description: be_present,
              category: be_present,
              subcategory: be_present,
              flavor_profiles: array_including(be_present),
              primary_flavor: be_present,
              price_range: match(/\$+/),
              attributes: be_present,
              texture: be_present
            }
          )
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
