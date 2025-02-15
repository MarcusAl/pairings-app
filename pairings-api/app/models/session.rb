# == Schema Information
#
# Table name: sessions
#
#  id         :uuid             not null, primary key
#  expires_at :datetime         not null
#  ip_address :string
#  user_agent :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Session < ApplicationRecord
  DEFAULT_EXPIRATION = 45.days
  belongs_to :user

  validate :not_expired, if: -> { expires_at.present? }

  scope :active, -> { where('expires_at > ?', Time.now) }

  before_create do
    self.user_agent = Current.user_agent
    self.ip_address = Current.ip_address
  end

  def self.generate_expiration
    DEFAULT_EXPIRATION.from_now
  end

  def expired?
    expires_at < Time.zone.now
  end

  private

  def not_expired
    if expired?
      errors.add(:base, 'Session has expired')
    end
  end
end
