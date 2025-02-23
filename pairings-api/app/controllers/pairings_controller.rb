class PairingsController < ApplicationController
  before_action :set_pairing, only: [:show, :destroy, :update]

  has_scope :visible_to
  has_scope :by_strength
  has_scope :by_confidence
  has_scope :public_pairings, type: :boolean
  has_scope :private_pairings, type: :boolean

  def index
    pagy, pairings = pagy(apply_scopes(Pairing).all.order(created_at: :desc))

    render json: { data: pairings, meta: pagy_metadata(pagy) }
  end

  def show
    render json: { data: @pairing }, status: :ok
  end

  def create
    if params[:item1_id].present? && item = current_user.items.find(params[:item1_id])
      PairingJob.perform_now(item, current_user)

      render json: { data: item.id }, status: :created
    else
      render json: { error: ["Item 1 must exist"] }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::NotNullViolation
    render json: { error: 'Bad Request' }, status: :bad_request
  end 

  def update
    @pairing.update!(pairing_params)

    render json: { data: @pairing }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Not Found' }, status: :not_found
  rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::NotNullViolation
    render json: { error: 'Bad Request' }, status: :bad_request
  end

  def destroy
    @pairing.destroy!
    render json: { data: { message: 'Pairing deleted' } }, status: :ok
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: { error: 'Failed to delete' }, status: :unprocessable_entity
  end

  private

  def set_pairing
    @pairing = current_user.pairings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Not Found' }, status: :not_found
  end

  def pairing_params
    params.permit(:public, :strength, :confidence_score, :ai, :pairing_notes, :item1_id, :item2_id)
  end
end
