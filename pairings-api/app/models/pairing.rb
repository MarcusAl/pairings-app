# == Schema Information
#
# Table name: pairings
#
#  id               :uuid             not null, primary key
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
class Pairing < ApplicationRecord
  belongs_to :user
  belongs_to :item1, class_name: 'Item'
  belongs_to :item2, class_name: 'Item'

  validates :strength, inclusion: { in: 1..5 }, allow_nil: true
  validates :confidence_score, inclusion: { in: 0..1 }, allow_nil: true
  validates :item1_id, uniqueness: { scope: [:item2_id, :user_id] }

  scope :visible_to, ->(user) {
    where('user_id = ? OR public = true', user.id)
  }

  scope :by_strength, ->(min_strength) {
    where('strength >= ?', min_strength)
  }

  scope :by_confidence, ->(min_confidence) {
    where('confidence_score >= ?', min_confidence)
  }

  scope :public_pairings, -> { where(public: true) }
  scope :private_pairings, -> { where(public: false) }

  validate :different_items
  
  private

  def different_items
    if item1_id == item2_id
      errors.add :base, :invalid, message: "Can't pair an item with itself"
    end
  end
end
