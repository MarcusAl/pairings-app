module Web
  class SessionsController < BaseController
    skip_before_action :authenticate, only: %i[new create]

    def new
      redirect_to web_root_path if current_user
    end

    def create
      user = User.authenticate_by(auth_params)

      if user
        log_in(user)
        redirect_to web_root_path, notice: 'Signed in.'
      else
        flash.now[:alert] = 'Invalid email or password.'
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      log_out
      redirect_to web_login_path, notice: 'Signed out.'
    end

    private

    def auth_params
      params.permit(:email, :password)
    end
  end
end
