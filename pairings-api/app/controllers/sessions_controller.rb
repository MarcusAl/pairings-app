class SessionsController < ApplicationController
  skip_before_action :authenticate, only: :create

  before_action :set_session, only: %i[show]

  def index
    render json: Current.user.sessions.active.order(created_at: :desc)
  end

  def show
    render json: {
      session: @session,
      access_token: @session.signed_id
    }
  end

  def create
    if user = User.authenticate_by(auth_params)
      @session = user.sessions.create!(
        expires_at: Session.generate_expiration
      )
      response.set_header 'X-Session-Token', @session.signed_id

      render json: {
        session: @session,
        access_token: @session.signed_id
      }, status: :created
    else
      render json: { error: 'That email or password is incorrect' }, status: :unauthorized
    end
  end

  def destroy
    if Current.session&.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def set_session
    @session = Session.find(params[:id])
  end

  def auth_params
    params.slice(:email, :password).permit(:email, :password)
  end
end

