# == Schema Information
#
# Table name: items
#
#  id                     :uuid             not null, primary key
#  category               :string           not null
#  description            :text
#  flavor_profiles        :string           default([]), is an Array
#  item_attributes        :json
#  name                   :string
#  price_range            :string
#  primary_flavor_profile :string
#  public                 :boolean          default(FALSE)
#  subcategory            :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :uuid             not null
#
# Indexes
#
#  index_items_on_flavor_profiles  (flavor_profiles) USING gin
#  index_items_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    subject { build(:item) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:primary_flavor_profile) }
    it { should validate_presence_of(:flavor_profiles) }
    it { should validate_inclusion_of(:category).in_array(Item::CATEGORIES.keys) }
    it { should validate_inclusion_of(:price_range).in_array(Item::PRICE_RANGES.keys) }
    
    it 'validates primary_flavor_profile is included in flavor_profiles' do
      item = build(:item, primary_flavor_profile: 'umami', flavor_profiles: ['sweet', 'salty'])
      expect(item).not_to be_valid
      expect(item.errors[:primary_flavor_profile]).to include("must be included in flavor profiles")
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:pairings_as_item1) }
    it { should have_many(:pairings_as_item2) }
    it { should have_one_attached(:image) }
  end

  describe 'scopes' do
    let!(:user) { create(:user) }
    let!(:public_item) { create(:item, :public) }
    let!(:private_item) { create(:item, user: user) }
    let!(:other_private_item) { create(:item) }

    describe '.visible_to' do
      it 'returns public items and user\'s own items' do
        visible_items = Item.visible_to(user)
        expect(visible_items).to include(public_item, private_item)
        expect(visible_items).not_to include(other_private_item)
      end
    end

    describe '.by_flavor_profile' do
      let!(:sweet_salty_item) { create(:item, flavor_profiles: ['sweet', 'salty']) }
      let!(:sweet_item) { create(:item, flavor_profiles: ['sweet']) }
      
      it 'returns items with matching flavor profiles' do
        expect(Item.by_flavor_profile(['sweet'])).to include(sweet_salty_item, sweet_item)
        expect(Item.by_flavor_profile(['salty'])).to include(sweet_salty_item)
        expect(Item.by_flavor_profile(['salty'])).not_to include(sweet_item)
      end
    end
  end

  describe '#paired_items' do
    let(:food) { create(:item) }
    let(:drink) { create(:item, :drink) }
    let!(:pairing) { create(:pairing, item1: food, item2: drink) }

    it 'returns all paired items' do
      expect(food.paired_items).to include(drink)
      expect(drink.paired_items).to include(food)
    end
  end
end
