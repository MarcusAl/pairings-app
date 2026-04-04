module Web
  class RegistrationsController < BaseController
    skip_before_action :authenticate, only: %i[new create]

    def new
      redirect_to web_root_path if current_user
      @user = User.new
    end

    def create
      @user = User.new(registration_params)

      if @user.save
        log_in(@user)
        redirect_to web_root_path, notice: t('.notice')
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def registration_params
      params.expect(user: %i[email password password_confirmation])
    end
  end
end
