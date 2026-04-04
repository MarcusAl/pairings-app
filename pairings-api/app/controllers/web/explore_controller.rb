module Web
  class ExploreController < BaseController
    skip_before_action :authenticate

    has_scope :by_category
    has_scope :search

    def items
      @pagy, @items = pagy(apply_scopes(Item.public_items).order(created_at: :desc))
    end

    def pairings
      @pagy, @pairings = pagy(
        Pairing.public_pairings.includes(:item1, :item2).order(created_at: :desc)
      )
    end
  end
end
