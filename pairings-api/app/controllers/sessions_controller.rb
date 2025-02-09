class SessionsController < ApplicationController
  skip_before_action :authenticate, only: :create

  before_action :set_session, only: %i[show]

  def index
    render json: { data: current_user.sessions.active.order(created_at: :desc) }, status: :ok
  end

  def show
    render json: { data: @session }, status: :ok
  end

  def create
    if user = User.authenticate_by(auth_params)
      @session = user.sessions.create!(
        expires_at: Session.generate_expiration
      )
      response.set_header 'X-Session-Token', @session.signed_id

      render json: { data: @session }, status: :created
    else
      render json: { error: 'That email or password is incorrect' }, status: :unauthorized
    end
  end

  def destroy
    Current.session&.destroy

    render json: { data: { message: 'Session destroyed' } }, status: :ok
  rescue ActiveRecord::RecordNotDestroyed
    render json: { error: 'Failed to destroy session' }, status: :unprocessable_entity
  end

  private

  def set_session
    @session = current_user.sessions.find(params[:id])

  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Session not found' }, status: :not_found 
  end

  def auth_params
    params.slice(:email, :password).permit(:email, :password)
  end
end

