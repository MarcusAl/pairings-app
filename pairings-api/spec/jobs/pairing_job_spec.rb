require 'rails_helper'

RSpec.describe PairingJob, type: :job do
  describe '#perform' do
    let(:user) { create(:user) }
    let!(:item) { create(:item, :with_image, user: user) }

    subject { described_class.perform_now(item, user) }

    cassette_name = 'pairing_service/valid_response'

    it 'creates a second item and a pairing', vcr: { cassette_name: cassette_name } do
      expect { subject }.to change(Item, :count).by(1).and change(Pairing, :count).by(1)

      expect(AttachImageJob).to have_been_enqueued
    end

    context 'when creation fails', vcr: { cassette_name: cassette_name } do
      before do
        allow(item).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new)
      end

      it 'does not create items or pairings' do
        expect(Item.count).to eq(1)
        expect(Pairing.count).to eq(0)
        expect { subject }.to raise_error(PairingJob::PairingJobError)

        expect(AttachImageJob).not_to have_been_enqueued
      end
    end
  end
end
