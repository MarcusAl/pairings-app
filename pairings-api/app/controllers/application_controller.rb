class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Pagy::Backend

  before_action :set_current_request_details
  before_action :authenticate

  private

  def authenticate
    session_record = authenticate_with_http_token { |token, _| Session.find_signed(token) }
    
    if session_record && !session_record.expired?
      Current.session = session_record
      Current.user = session_record.user
    else
      request_http_token_authentication
    end
  end

  def current_user
    Current.user
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end
