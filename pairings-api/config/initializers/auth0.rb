AUTH0_MIDDLEWARE_CONFIG = Rails.application.config_for(:auth0_middleware)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    AUTH0_MIDDLEWARE_CONFIG["client_id"],
    AUTH0_MIDDLEWARE_CONFIG["client_secret"],
    AUTH0_MIDDLEWARE_CONFIG["issuer_domain"],
    callback_path: "/auth/auth0/callback",
    authorize_params: {
      scope: "openid profile email"
    }
  )
end

# Allow both GET and POST methods for OmniAuth
OmniAuth.config.silence_get_warning = true
OmniAuth.config.request_validation_phase = nil
OmniAuth.config.allowed_request_methods = [:post, :get]

# Auth0 OmniAuth failure handling
OmniAuth.config.on_failure = Proc.new { |env|
  Auth0Controller.action(:failure).call(env)
}
