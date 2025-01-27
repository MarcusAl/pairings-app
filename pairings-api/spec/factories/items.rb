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
FactoryBot.define do
  factory :item do
    association :user
    name { Faker::Food.dish }
    description { Faker::Food.description }
    category { 'food' }
    subcategory { nil }
    price_range { '$' }
    primary_flavor_profile { 'sweet' }
    flavor_profiles { ['sweet', 'salty'] }
    public { false }

    trait :drink do
      name { Faker::Beer.name }
      category { 'drink' }
    end

    trait :public do
      public { true }
    end

    trait :with_image do
      after(:build) do |item|
        item.image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
