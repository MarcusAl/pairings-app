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
        redirect_to web_root_path, notice: t('.notice')
      else
        flash.now[:alert] = t('.alert')
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      log_out
      redirect_to web_login_path, notice: t('.notice')
    end

    private

    def auth_params
      params.permit(:email, :password)
    end
  end
end
