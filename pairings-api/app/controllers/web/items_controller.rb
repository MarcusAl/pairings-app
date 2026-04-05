module Web
  class ItemsController < BaseController
    before_action :set_item, only: %i[show edit update destroy]

    has_scope :by_category, type: :array
    has_scope :by_flavor_profile, type: :array
    has_scope :search

    def index
      @pagy, @items = pagy(apply_scopes(current_user.items).order(created_at: :desc))
    end

    def show; end

    def new
      @item = current_user.items.build
    end

    def edit; end

    def create
      @item = current_user.items.build(item_params)

      if @item.save
        redirect_to web_item_path(@item), notice: t('.notice')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @item.update(item_params)
        redirect_to web_item_path(@item), notice: t('.notice')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @item.destroy!
      redirect_to web_items_path, notice: t('.notice')
    end

    private

    def set_item
      @item = current_user.items.find(params[:id])
    end

    def item_params
      params.expect(
        item: [
          :name,
          :description,
          :image,
          :category,
          :subcategory,
          :primary_flavor_profile,
          :price_range,
          :public,
          { flavor_profiles: [] }
        ]
      )
    end
  end
end
