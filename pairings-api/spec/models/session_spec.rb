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
require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'validations' do
    subject { build(:session) }

    it { should have_db_column(:expires_at).of_type(:datetime) }
    it { should belong_to(:user) }
  end

  describe 'scopes' do
    let!(:active_session) { create(:session, expires_at: 1.day.from_now) }
    let!(:expired_session) { create(:session, :expired) }

    describe '.active' do
      it 'returns only non-expired sessions' do
        expect(Session.active).to include(active_session)
        expect(Session.active).not_to include(expired_session)
      end
    end
  end

  describe '#expired?' do
    it 'returns true for expired sessions' do
      session = build(:session, expires_at: 1.day.ago)
      expect(session).to be_expired
    end

    it 'returns false for active sessions' do
      session = build(:session, expires_at: 1.day.from_now)
      expect(session).not_to be_expired
    end
  end

  describe '.generate_expiration' do
    it 'returns a timestamp 45 days from now' do
      expiration = Session.generate_expiration
      expect(expiration).to be_within(1.second).of(Session::DEFAULT_EXPIRATION.from_now)
    end
  end

  describe 'validation' do
    it 'is not valid if expired' do
      session = build(:session, expires_at: 1.day.ago)
      expect(session).not_to be_valid
      expect(session.errors[:base]).to include('Session has expired')
    end

    it 'is valid if not expired' do
      session = build(:session, expires_at: 1.day.from_now)
      expect(session).to be_valid
    end
  end
end
