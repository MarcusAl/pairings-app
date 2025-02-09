# == Schema Information
#
# Table name: pairings
#
#  id               :uuid             not null, primary key
#  ai               :boolean          default(FALSE)
#  ai_reasoning     :text
#  confidence_score :float
#  pairing_notes    :text
#  public           :boolean          default(FALSE)
#  strength         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  item1_id         :uuid             not null
#  item2_id         :uuid             not null
#  user_id          :uuid             not null
#
# Indexes
#
#  index_pairings_on_item1_id                           (item1_id)
#  index_pairings_on_item1_id_and_item2_id_and_user_id  (item1_id,item2_id,user_id) UNIQUE
#  index_pairings_on_item2_id                           (item2_id)
#  index_pairings_on_user_id                            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (item1_id => items.id)
#  fk_rails_...  (item2_id => items.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Pairing, type: :model do
  describe 'validations' do
    subject { build(:pairing) }

    it { should validate_inclusion_of(:strength).in_range(1..5).allow_nil }
    it { should validate_inclusion_of(:confidence_score).in_range(0..1).allow_nil }
    
    it 'validates uniqueness of item1_id scoped to item2_id and user_id' do
      pairing = create(:pairing)
      duplicate = build(:pairing, 
        item1: pairing.item1, 
        item2: pairing.item2, 
        user: pairing.user
      )
      expect(duplicate).not_to be_valid
    end

    it 'prevents self-pairing' do
      item = create(:item)
      pairing = build(:pairing, item1: item, item2: item)
      expect(pairing).not_to be_valid
      expect(pairing.errors[:base]).to include("Can't pair an item with itself")
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:item1) }
    it { should belong_to(:item2) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:public_pairing) { create(:pairing, :public) }
    let!(:private_pairing) { create(:pairing, user: user) }
    let!(:other_private_pairing) { create(:pairing) }

    describe '.visible_to' do
      it 'returns public pairings and user\'s own pairings' do
        visible = Pairing.visible_to(user)
        expect(visible).to include(public_pairing, private_pairing)
        expect(visible).not_to include(other_private_pairing)
      end
    end

    describe '.by_strength' do
      let!(:strong_pairing) { create(:pairing, strength: 5) }
      let!(:weak_pairing) { create(:pairing, strength: 2) }

      it 'returns pairings with minimum strength' do
        expect(Pairing.by_strength(4)).to include(strong_pairing)
        expect(Pairing.by_strength(4)).not_to include(weak_pairing)
      end
    end
  end
end
