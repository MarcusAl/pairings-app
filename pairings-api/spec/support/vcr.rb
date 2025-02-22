require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  
  config.filter_sensitive_data('<ANTHROPIC_API_KEY>') { ENV.fetch('ANTHROPIC_API_KEY', 'test') }
  config.filter_sensitive_data('<SYSTEM_PROMPT>') do |interaction|
    interaction.request.body.match(/\"system\":\"([^"]+)\"/)[1]
  end
  config.filter_sensitive_data('<ENCODED_IMAGE_DATA>') do |interaction|
    if interaction.request.body&.include?('base64')
      interaction.request.body.match(/\"data\":\"([^\"]+)\"/)[1]
    end
  end
  
  config.default_cassette_options = {
    record: ENV['CI'] ? :none : :once,
    match_requests_on: [:method, :uri],
    allow_playback_repeats: true
  }
end
