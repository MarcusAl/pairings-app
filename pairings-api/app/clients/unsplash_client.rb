class UnsplashClient
  CACHE_KEY_PREFIX = 'unsplash_food_images'.freeze
  CACHED_KEY_PREFIX = 'unsplash_food_images_cached'.freeze
  CACHE_DURATION = 1.hour
  API_URL = 'https://api.unsplash.com/photos/random'.freeze

  def self.food_images(count: 9)
    Rails.cache.fetch("#{CACHE_KEY_PREFIX}/#{count}", expires_in: CACHE_DURATION) do
      fetch_images(count)
    end
  end

  def self.fetch_images(count)
    access_key = Rails.application.credentials.dig(:unsplash, :access_key)
    return cached_or_fallback(count) unless access_key

    response = request_photos(access_key, count)
    return cached_or_fallback(count) unless response.is_a?(Net::HTTPSuccess)

    images = parse_photos(response.body)
    Rails.cache.write("#{CACHED_KEY_PREFIX}/#{count}", images)
    images
  rescue StandardError
    cached_or_fallback(count)
  end

  def self.request_photos(access_key, count)
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(query: 'gourmet food plating or wine', count: count, orientation: 'landscape')

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Client-ID #{access_key}"
    request['Accept-Version'] = 'v1'

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 5) do |http|
      http.request(request)
    end
  end

  def self.parse_photos(body)
    JSON.parse(body).map do |photo|
      {
        url: photo.dig('urls', 'regular'),
        alt: photo['alt_description'] || 'Gourmet food',
        credit: photo.dig('user', 'name'),
        credit_url: photo.dig('user', 'links', 'html')
      }
    end
  end

  def self.cached_or_fallback(count)
    Rails.cache.read("#{CACHED_KEY_PREFIX}/#{count}") || fallback_images
  end

  def self.fallback_images
    [
      { url: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800', alt: 'Gourmet food plating', credit: 'Unsplash', credit_url: 'https://unsplash.com' },
      { url: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800', alt: 'Fine dining dish', credit: 'Unsplash', credit_url: 'https://unsplash.com' },
      { url: 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=800', alt: 'Artisan food preparation', credit: 'Unsplash', credit_url: 'https://unsplash.com' },
      { url: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800', alt: 'Wine glasses', credit: 'Unsplash', credit_url: 'https://unsplash.com' },
      { url: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800', alt: 'Plated pancakes with berries', credit: 'Unsplash', credit_url: 'https://unsplash.com' },
      { url: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800', alt: 'Fresh salad bowl', credit: 'Unsplash', credit_url: 'https://unsplash.com' },
      { url: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800', alt: 'Artisan pizza', credit: 'Unsplash', credit_url: 'https://unsplash.com' },
      { url: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=800', alt: 'Chocolate dessert', credit: 'Unsplash', credit_url: 'https://unsplash.com' },
      { url: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=800', alt: 'Pasta dish', credit: 'Unsplash', credit_url: 'https://unsplash.com' }
    ]
  end

  private_class_method :fetch_images, :request_photos, :parse_photos, :cached_or_fallback
end
