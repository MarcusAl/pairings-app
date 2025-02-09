class PasswordsController < ApplicationController
  def update
    current_user.update!(user_params)

    render json: { data: current_user }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Not Found' }, status: :not_found
  rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::NotNullViolation
    render json: { error: 'Bad Request' }, status: :bad_request
  end

  private

  def user_params
    params.permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: '')
  end
end
