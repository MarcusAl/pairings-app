class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user_agent
  attribute :ip_address
  attribute :user

  delegate :user, to: :session, allow_nil: true
end

