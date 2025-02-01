Anthropic.configure do |config|
  config.access_token = ENV.fetch("ANTHROPIC_API_KEY")
  config.headers = {
    "anthropic-version" => "2023-06-01",
    "content-type" => "application/json",
  }
end

CLAUDE_PROMPT = YAML.load_file(Rails.root.join('config', 'prompts.yml'))
