require 'faraday'
require 'faraday/middleware'

Anthropic.configure do |config|
  config.access_token = ENV["ANTHROPIC_API_KEY"] || Rails.application.credentials.anthropic_api_key
  config.anthropic_version = ENV["ANTHROPIC_API_VERSION"] || Rails.application.credentials.anthropic_api_version
  config.request_timeout = 240
end

CLAUDE_PROMPTS = YAML.load_file(Rails.root.join('config', 'prompts.yml'))
ANTHROPIC_MODEL = ENV["ANTHROPIC_MODEL"] || Rails.application.credentials.anthropic_model
