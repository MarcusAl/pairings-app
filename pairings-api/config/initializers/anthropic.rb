CLAUDE_PROMPTS = YAML.load_file(Rails.root.join('config', 'prompts.yml'))
ANTHROPIC_MODEL = ENV["ANTHROPIC_MODEL"] || Rails.application.credentials.anthropic_model
