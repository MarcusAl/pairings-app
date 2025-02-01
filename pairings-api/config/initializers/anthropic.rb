require 'faraday'
require 'faraday/middleware'

Anthropic.configure do |config|
  config.access_token = ENV.fetch("ANTHROPIC_API_KEY")
  config.anthropic_version = ENV.fetch("ANTHROPIC_API_VERSION")
  config.request_timeout = 240
end

CLAUDE_PROMPTS = YAML.load_file(Rails.root.join('config', 'prompts.yml'))
ANTHROPIC_MODEL = ENV.fetch("ANTHROPIC_MODEL")
