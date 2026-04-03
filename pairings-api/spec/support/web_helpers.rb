module WebHelpers
  def sign_in(user)
    post web_login_path, params: { email: user.email, password: 'Secret1*3*5*' }
  end
end

RSpec.configure do |config|
  config.include WebHelpers, type: :request
end
