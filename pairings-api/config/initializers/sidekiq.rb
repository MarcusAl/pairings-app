redis_config = { url: ENV['REDIS_URL'] || 'redis://redis:6379/1', ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE} }

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
  config.logger.level = Logger::WARN if Rails.env.production?
end

Sidekiq.strict_args!
