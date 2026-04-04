class UnsplashClient
  CACHE_KEY = 'unsplash_food_images'.freeze
  CACHE_DURATION = 1.hour
  API_URL = 'https://api.unsplash.com/photos/random'.freeze

  def self.food_images(count: 6)
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_DURATION) do
      fetch_images(count)
    end
  end

  def self.fetch_images(count)
    access_key = Rails.application.credentials.dig(:unsplash, :access_key)
    return fallback_images unless access_key

    response = request_photos(access_key, count)
    return fallback_images unless response.is_a?(Net::HTTPSuccess)

    parse_photos(response.body)
  rescue StandardError
    fallback_images
  end

  def self.request_photos(access_key, count)
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(query: 'gourmet food plating', count: count, orientation: 'landscape')

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

  def self.fallback_images
    [{ url: nil, alt: 'Gourmet food', credit: nil, credit_url: nil }]
  end

  private_class_method :fetch_images, :request_photos, :parse_photos
end
