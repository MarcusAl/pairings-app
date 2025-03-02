class Auth0Controller < ApplicationController
  skip_before_action :authenticate

  def callback
    auth_info = request.env['omniauth.auth']
    
    begin
      ActiveRecord::Base.transaction do
        user = User.find_or_initialize_by(email: auth_info.dig('info', 'email'))
        user.password = SecureRandom.hex(20) if user.new_record?
        user.save!

        session = user.sessions.create!
      
        Current.session = session
        Current.user = user
        
        render json: { 
          data: {
            token: session.signed_id,
            user: user.as_json(only: [:id, :email])
          }
        } and return
      end
    rescue StandardError => e
      Rails.logger.error("Auth0 callback failed: #{e.message}")
      redirect_to '/auth/failure', error: 'Authentication failed'
    end
  end

  def failure
    render json: { error: 'Authentication failed' }, status: :unauthorized
  end

  def logout
    Current.session&.destroy

    render json: {
      data: {
        logout_url: logout_url
      }
    }
  end

  def auth
  end

  private

  def logout_url
    request_params = {
      returnTo: Rails.env.production? ? Rails.application.credentials.base_url : ENV['BASE_URL'],
      client_id: Rails.env.production? ? Rails.application.credentials.auth0_client_id : ENV['AUTH0_CLIENT_ID']
    }.to_s
  
    URI::HTTPS.build(host: Rails.env.production? ? Rails.application.credentials.auth0_domain : ENV['AUTH0_DOMAIN'], path: '/v2/logout', query: request_params).to_s
  end
end
