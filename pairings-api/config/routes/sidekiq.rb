require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"] || Rails.application.credentials.sidekiq_username)) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"] || Rails.application.credentials.sidekiq_password))
end

mount Sidekiq::Web => "admin/sidekiq"
