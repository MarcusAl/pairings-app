require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), Digest::SHA256.hexdigest(Rails.env.production? ? Rails.application.credentials.sidekiq_username : ENV["SIDEKIQ_USERNAME"])) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), Digest::SHA256.hexdigest(Rails.env.production? ? Rails.application.credentials.sidekiq_password : ENV["SIDEKIQ_PASSWORD"]))
end

mount Sidekiq::Web => "admin/sidekiq"
