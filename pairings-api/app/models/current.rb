class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user_agent
  attribute :ip_address
  attribute :user

  def user=(user)
    super
    self.session = nil
  end

  def session=(session)
    super
    self.user = session&.user
  end
end

