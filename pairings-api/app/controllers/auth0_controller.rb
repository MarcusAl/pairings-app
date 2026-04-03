class Auth0Controller < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, only: :callback

  def callback
    auth_info = request.env['omniauth.auth']

    ActiveRecord::Base.transaction do
      user = User.find_or_initialize_by(email: auth_info.dig('info', 'email'))
      user.password = SecureRandom.hex(20) if user.new_record?
      user.save!

      session_record = user.sessions.create!(expires_at: Session.generate_expiration)
      Current.session = session_record
      Current.user = user

      if request.format.json?
        render json: { data: { token: session_record.signed_id, user: user.as_json(only: %i[id email]) } }
      else
        session[:current_session_id] = session_record.id
        redirect_to web_root_path, notice: 'Signed in with Auth0.'
      end
    end
  rescue StandardError => e
    Rails.logger.error("Auth0 callback failed: #{e.message}")
    if request.format.json?
      render json: { error: 'Authentication failed' }, status: :unauthorized
    else
      redirect_to web_login_path, alert: 'Authentication failed.'
    end
  end

  def failure
    if request.format.json?
      render json: { error: 'Authentication failed' }, status: :unauthorized
    else
      redirect_to web_login_path, alert: 'Authentication failed.'
    end
  end

  def logout
    Current.session&.destroy

    if request.format.json?
      render json: { data: { logout_url: logout_url } }
    else
      reset_session
      redirect_to logout_url, allow_other_host: true
    end
  end

  private

  def logout_url
    request_params = {
      returnTo: ENV['BASE_URL'] || Rails.application.credentials.base_url,
      client_id: ENV['AUTH0_CLIENT_ID'] || Rails.application.credentials.auth0_client_id
    }.to_s

    URI::HTTPS.build(
      host: ENV['AUTH0_DOMAIN'] || Rails.application.credentials.auth0_domain,
      path: '/v2/logout',
      query: request_params
    ).to_s
  end
end
