class Auth0Controller < ApplicationController
  skip_before_action :authenticate

  def callback
    auth_info = request.env['omniauth.auth']
    
    user = User.find_or_initialize_by(email: auth_info.dig('info', 'email'))
    user.password = SecureRandom.hex(20) if user.new_record?
    user.save!

    session = user.sessions.create!(expires_at: auth_info.dig('credentials', 'expires_at'))
    
    Current.session = session
    Current.user = user
    
    render json: { 
      token: session.signed_id,
      user: user.as_json(only: [:id, :email])
    }
  end

  def failure
    render json: { error: 'Authentication failed' }, status: :unauthorized
  end

  def logout
    Current.session&.destroy
  end

  def auth
  end
end
