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
FactoryBot.define do
  factory :pairing do
    association :user
    association :item1, factory: :item
    association :item2, factory: :item, category: 'drink'
    strength { 4 }
    pairing_notes { "Great combination!" }
    confidence_score { 0.85 }
    public { false }
    ai_reasoning { "These items complement each other well because..." }

    trait :public do
      public { true }
    end
  end
end
