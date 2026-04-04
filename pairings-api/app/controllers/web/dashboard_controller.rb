module Web
  class DashboardController < BaseController
    def index
      @recent_items = current_user.items.order(created_at: :desc).limit(5)
      @recent_pairings = current_user.pairings
                                     .includes(:item1, :item2)
                                     .order(created_at: :desc)
                                     .limit(5)
      @carousel_images = UnsplashService.food_images
    end
  end
end
