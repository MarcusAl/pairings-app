class SessionsController < ApplicationController
  def create
    @user = User.authenticate_by(user_params)
    if @user&.present?
      session[:user_id] = @user.id
      render json: { user: @user }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
