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
FactoryBot.define do
  factory :session do
    association :user
    expires_at { Session::DEFAULT_EXPIRATION.from_now }
    user_agent { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)' }
    ip_address { '127.0.0.1' }

    trait :expired do
      after(:create) do |session|
        session.update_column(:expires_at, 1.day.ago)
      end
    end
  end
end
