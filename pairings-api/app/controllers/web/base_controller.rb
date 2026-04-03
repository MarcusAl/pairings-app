module Web
  class BaseController < ActionController::Base
    protect_from_forgery with: :exception
    layout 'web'

    before_action :set_current_request_details
    before_action :restore_session
    before_action :authenticate

    helper_method :current_user

    private

    # NOTE: We use :current_session_id rather than :session_id because Rack
    # reserves session[:session_id] for its own internal session identifier.
    def restore_session
      session_record = Session.find_by(id: session[:current_session_id])
      return unless session_record && !session_record.expired?

      Current.session = session_record
      Current.user = session_record.user
    end

    def authenticate
      redirect_to web_login_path, alert: 'Please sign in.' unless current_user
    end

    def log_in(user)
      session_record = user.sessions.create!(expires_at: Session.generate_expiration)
      session[:current_session_id] = session_record.id
      Current.session = session_record
      Current.user = user
    end

    def log_out
      Current.session&.destroy
      reset_session
    end

    def current_user
      Current.user
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end
  end
end
