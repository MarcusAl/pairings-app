module Web
  class PairingsController < BaseController
    before_action :set_pairing, only: %i[show destroy]

    def index
      pairings = current_user.pairings.includes(:item1, :item2).order(created_at: :desc)
      @pagy, @pairings = pagy(pairings)
    end

    def show; end

    def new
      @items = current_user.items.order(:name)
    end

    def create
      item = current_user.items.find(params[:item1_id])
      PairingJob.perform_later(item, current_user)
      redirect_to web_pairings_path, notice: t('.notice')
    end

    def destroy
      @pairing.destroy!
      redirect_to web_pairings_path, notice: t('.notice')
    end

    private

    def set_pairing
      @pairing = current_user.pairings.find(params[:id])
    end
  end
end
