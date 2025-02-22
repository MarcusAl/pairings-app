require 'rails_helper'

RSpec.describe PairingService do
  describe '#call' do
    let(:image) { fixture_file_upload('spec/fixtures/steak.jpg', 'image/jpeg') }
    let(:blob) { ActiveStorage::Blob.create_and_upload!(io: image, filename: 'steak.jpg') }
    
    context 'with valid response' do
      it 'returns a successful pairing object', vcr: { cassette_name: 'pairing_service/valid_response' } do
        result = described_class.call(blob_image_id: blob.id)
        
        aggregate_failures do
          expect(result[:success?]).to be true
          expect(result[:payload][:item1].keys).to match_array(Item::FIELDS)
          expect(result[:payload][:item2].keys).to match_array(Item::FIELDS)
          expect(result[:payload]).to match(
            item1: {
              name: match(/\A\S.*\S\z/),
              description: be_present,
              category: be_in(Item::CATEGORIES.keys),
              subcategory: be_present,
              flavor_profiles: array_including(be_present),
              primary_flavor_profile: be_present,
              price_range: be_in(Item::PRICE_RANGES.keys)
            },
            item2: {
              name: match(/\A\S.*\S\z/),
              description: be_present,
              category: be_in(Item::CATEGORIES.keys),
              subcategory: be_present,
              flavor_profiles: array_including(be_present),
              primary_flavor_profile: be_present,
              price_range: be_in(Item::PRICE_RANGES.keys)
            },
            image_url: be_a(String).and(match(/\Ahttps?:\/\//)),
            pairing: {
              ai_reasoning: be_a(String).and(be_present),
              confidence_score: be_a(Float).and(be_between(0, 1)),
              pairing_notes: be_a(String).and(be_present),
              strength: be_a(Integer).and(be_between(1, 5))
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
            
          expect { described_class.call(blob_image_id: blob.id) }
            .to raise_error(PairingService::TooManyRequestsError)
        end
      end
      
      it 'handles invalid responses' do
        VCR.use_cassette('pairing_service/invalid_response') do
          allow_any_instance_of(Anthropic::Client).to receive(:messages)
            .and_return({ 'content' => [{ 'text' => 'Invalid|Response' }] })
            
          expect { described_class.call(blob_image_id: blob.id) }
            .to raise_error(PairingService::ParseError)
        end
      end
    end
  end
end
