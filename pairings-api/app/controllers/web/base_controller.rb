module Web
  class BaseController < ActionController::Base
    include Pagy::Method

    protect_from_forgery with: :exception
    layout 'web'

    before_action :set_locale
    before_action :set_current_request_details
    before_action :restore_session
    before_action :authenticate

    helper_method :current_user, :available_locales

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
      redirect_to web_login_path, alert: t('web.base.authenticate.alert') unless current_user
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

    def set_locale
      locale = params[:locale] || session[:locale] || I18n.default_locale
      I18n.locale = I18n.available_locales.include?(locale.to_sym) ? locale.to_sym : I18n.default_locale
      session[:locale] = I18n.locale
    end

    def available_locales
      @available_locales ||= I18n.available_locales.select do |loc|
        I18n.exists?(:language_name, loc)
      end
    end

    def default_url_options
      { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end
  end
end
