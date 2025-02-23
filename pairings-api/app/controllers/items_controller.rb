class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :destroy, :update]

  has_scope :by_category
  has_scope :visible_to
  has_scope :by_flavor_profile, type: :array
  has_scope :search

  def index
    pagy, items = pagy(apply_scopes(current_user.items).order(created_at: :desc))

    render json: { data: items, meta: pagy_metadata(pagy) }
  end

  def show
    render json: { data: @item }, status: :ok
  end

  def create
    if item_params[:image].present?
      item = current_user.items.create!(item_params)
      render json: { data: item }, status: :created
    else
      render json: { error: ["Image must be attached"] }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::NotNullViolation
    render json: { error: 'Bad Request' }, status: :bad_request
  end

  def update
    @item.update!(item_params)

    render json: { data: @item }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Not Found' }, status: :not_found
  rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing, ActiveRecord::NotNullViolation
    render json: { error: 'Bad Request' }, status: :bad_request
  end

  def destroy
    @item.destroy!
    render json: { data: { message: 'Item deleted' } }, status: :ok
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: { error: 'Failed to delete' }, status: :unprocessable_entity
  end

  private

  def set_item
    @item = current_user.items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Not Found' }, status: :not_found
  end

  def item_params
    params.permit(:name, :description, :image, :category, :primary_flavor_profile, :price_range, :public, :item_attributes, flavor_profiles: [])
  end
end
