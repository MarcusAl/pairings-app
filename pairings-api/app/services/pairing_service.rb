class PairingService
  class PairingServiceError < StandardError; end
  class InvalidInputError < PairingServiceError; end
  class NotFoundError < PairingServiceError; end
  class TooManyRequestsError < PairingServiceError; end
  class InternalServerError < PairingServiceError; end
  class AnthropicOverloadedError < PairingServiceError; end
  class InvalidResponseError < PairingServiceError; end
  class ParseError < PairingServiceError; end
  class NoPairingFoundError < PairingServiceError; end

  require 'base64'

  ERROR_MAP = {
    Anthropic::Errors::BadRequestError => InvalidInputError,
    Anthropic::Errors::NotFoundError => NotFoundError,
    Anthropic::Errors::RateLimitError => TooManyRequestsError,
    Anthropic::Errors::InternalServerError => AnthropicOverloadedError
  }.freeze

  def self.call(blob_image_id:)
    new(blob_image_id).call
  end

  def initialize(blob_image_id)
    @blob_image_id = blob_image_id
  end

  def call
    return unless blob_image

    formatted_response = fetch_pairing

    { success?: true, payload: formatted_response }
  end

  private

  attr_reader :blob_image_id

  def fetch_pairing
    response = client.messages.create(
      model: ANTHROPIC_MODEL, system: prompt['system'],
      messages: prompt['messages'], max_tokens: 1000
    )
    text_response = response.content&.first&.text
    return if text_response.blank?

    parse_pairing_response(text_response)
  rescue Anthropic::Errors::APIError => e
    handle_error(e)
  end

  def blob_image
    @blob_image ||= ActiveStorage::Blob.find(blob_image_id)
  end

  def client
    @client ||= Anthropic::Client.new(
      api_key: ENV['ANTHROPIC_API_KEY'] || Rails.application.credentials.anthropic_api_key,
      timeout: 240
    )
  end

  def image_base64
    @image_base64 ||= Base64.strict_encode64(blob_image.download)
  end

  def prompt
    @prompt ||= CLAUDE_PROMPTS['claude']['message_with_image'].deep_dup.tap do |p|
      source = p.dig('messages', 0, 'content', 0, 'source')
      source['media_type'] = blob_image.content_type
      source['data'] = image_base64
    end
  end

  def parse_pairing_response(text_response)
    item1_values, item2_values = extract_pipe_lines(text_response)
    {
      item1: build_item_hash(item1_values), item2: build_item_hash(item2_values),
      image_url: item2_values[7], pairing: build_pairing_hash(item2_values)
    }.deep_symbolize_keys
  rescue ParseError
    raise
  rescue StandardError => e
    raise ParseError, "Failed to parse response: #{e.message}"
  end

  def extract_pipe_lines(text_response)
    pipe_lines = text_response.split("\n").reject(&:empty?).select { |l| l.include?('|') }
    raise ParseError, "Expected 2 pipe-delimited lines, got #{pipe_lines.size}" unless pipe_lines.size >= 2

    item1 = split_and_validate(pipe_lines[0], 7, 'Item1')
    item2 = split_and_validate(pipe_lines[1], 12, 'Item2')
    [item1, item2]
  end

  def split_and_validate(line, min_fields, label)
    values = line.split('|').map(&:strip)
    raise ParseError, "#{label} has #{values.size} fields, expected at least #{min_fields}" if values.size < min_fields

    values
  end

  def build_item_hash(values)
    Item::FIELDS.zip(values[0..6]).to_h.merge(
      flavor_profiles: (values[4] || '').split(',').map(&:strip)
    )
  end

  def build_pairing_hash(values)
    {
      confidence_score: values[8].to_f,
      ai_reasoning: values[9] || '',
      pairing_notes: values[10] || '',
      strength: (values[11] || '3').to_i.clamp(1, 5)
    }
  end

  def handle_error(error)
    mapped = ERROR_MAP.fetch(error.class) { PairingServiceError }
    raise mapped, error.message
  end
end
