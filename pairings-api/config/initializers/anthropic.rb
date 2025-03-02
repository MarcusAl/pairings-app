require 'faraday'
require 'faraday/middleware'

Anthropic.configure do |config|
  config.access_token = Rails.env.production? ? Rails.application.credentials.anthropic_api_key : ENV.fetch("ANTHROPIC_API_KEY")
  config.anthropic_version = Rails.env.production? ? Rails.application.credentials.anthropic_api_version : ENV.fetch("ANTHROPIC_API_VERSION")
  config.request_timeout = 240
end

CLAUDE_PROMPTS = YAML.load_file(Rails.root.join('config', 'prompts.yml'))
ANTHROPIC_MODEL = Rails.env.production? ? Rails.application.credentials.anthropic_model : ENV.fetch("ANTHROPIC_MODEL")
