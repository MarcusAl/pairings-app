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
class Item < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  
  has_many :pairings_as_item1, class_name: 'Pairing', foreign_key: 'item1_id', dependent: :destroy
  has_many :pairings_as_item2, class_name: 'Pairing', foreign_key: 'item2_id', dependent: :destroy
  
  CATEGORIES = {
    'main' => 'Main',
    'side' => 'Side',
    'dessert' => 'Dessert',
    'drink' => 'Drink',
    'wine' => 'Wine',
    'beer' => 'Beer',
    'spirits' => 'Spirits',
    'cider' => 'Cider',
    'tea' => 'Tea',
    'coffee' => 'Coffee',
    'other' => 'Other'
  }

  PRICE_RANGES = {
    '$' => 'Budget friendly (Under $15)',
    '$$' => 'Moderate ($15-30)',
    '$$$' => 'High-end ($30-60)',
    '$$$$' => 'Luxury ($60+)'
  }

  validates :price_range, inclusion: { in: PRICE_RANGES.keys }, presence: true
  validates :image, content_type: { in: [:png, :jpeg], spoofing_protection: true }, size: { less_than: 5.megabytes }
  validates :name, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES.keys }
  validates :primary_flavor_profile, presence: true
  validates :flavor_profiles, presence: true
  validate :flavor_profiles_include_primary

  scope :public_items, -> { where(public: true) }
  scope :private_items, -> { where(public: false) }
  scope :by_category, -> (category) { where(category: category) }
  scope :by_flavor_profile, -> (flavor_profile) { where('flavor_profiles @> ARRAY[?]::varchar[]', flavor_profile) }
  
  scope :visible_to, ->(user) {
    where('user_id = ? OR public = true', user.id)
  }

  scope :search, ->(query) {
    where('name ILIKE :q OR description ILIKE :q', q: "%#{query}%")
  }

  def paired_items
    Item.where(id: pairings_as_item1.select(:item2_id))
        .or(Item.where(id: pairings_as_item2.select(:item1_id)))
  end

  def image_url(expires_in: 30.minutes)
    return nil unless image.attached?
    
    case Rails.application.config.active_storage.service
    when :amazon
      image.blob.service_url(expires_in: expires_in)
    when :local, :test
      Rails.application.routes.url_helpers.rails_blob_url(image)
    end
  end

  def as_json(options = {})
    super(options).merge({
      image_url: image_url
    })
  end

  private

  def flavor_profiles_include_primary
    return if primary_flavor_profile.blank? || flavor_profiles.blank?
    
    unless flavor_profiles.include?(primary_flavor_profile)
      errors.add(:primary_flavor_profile, "must be included in flavor profiles")
    end
  end
end
