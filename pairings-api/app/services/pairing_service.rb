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

  def self.call(blob_image_id:)
    new(blob_image_id).call
  end

  def initialize(blob_image_id)
    @blob_image_id = blob_image_id
  end

  def call
    return unless blob_image

    formatted_response = get_pairing

    { success?: true, payload: formatted_response }
  end

  private

  attr_reader :blob_image_id

  def get_pairing
    response = client.messages.create(
      model: ANTHROPIC_MODEL,
      system: prompt['system'],
      messages: prompt['messages'],
      max_tokens: 1000
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
    @prompt ||= begin
      prompt = CLAUDE_PROMPTS['claude']['message_with_image'].deep_dup
      prompt['messages'][0]['content'][0]['source']['media_type'] = blob_image.content_type
      prompt['messages'][0]['content'][0]['source']['data'] = image_base64
      prompt
    end
  end

  def parse_pairing_response(text_response)
    lines = text_response.split("\n").reject(&:empty?)
    pipe_lines = lines.select { |l| l.include?('|') }

    raise ParseError, "Expected 2 pipe-delimited lines, got #{pipe_lines.size}" unless pipe_lines.size >= 2

    item1_values = pipe_lines[0].split('|').map(&:strip)
    item2_values = pipe_lines[1].split('|').map(&:strip)

    raise ParseError, "Item1 has #{item1_values.size} fields, expected at least 7" if item1_values.size < 7
    raise ParseError, "Item2 has #{item2_values.size} fields, expected at least 12" if item2_values.size < 12

    {
      item1: Hash[Item::FIELDS.zip(item1_values[0..6])].merge(
        flavor_profiles: (item1_values[4] || '').split(',').map(&:strip)
      ),
      item2: Hash[Item::FIELDS.zip(item2_values[0..6])].merge(
        flavor_profiles: (item2_values[4] || '').split(',').map(&:strip)
      ),
      image_url: item2_values[7],
      pairing: {
        confidence_score: item2_values[8].to_f,
        ai_reasoning: item2_values[9] || '',
        pairing_notes: item2_values[10] || '',
        strength: (item2_values[11] || '3').to_i.clamp(1, 5)
      }
    }.deep_symbolize_keys
  rescue ParseError
    raise
  rescue StandardError => e
    raise ParseError, "Failed to parse response: #{e.message}"
  end

  def handle_error(error)
    case error
    when Anthropic::Errors::BadRequestError
      raise InvalidInputError, error.message
    when Anthropic::Errors::NotFoundError
      raise NotFoundError, error.message
    when Anthropic::Errors::RateLimitError
      raise TooManyRequestsError, error.message
    when Anthropic::Errors::InternalServerError
      raise AnthropicOverloadedError, error.message
    else
      raise PairingServiceError, "Request failed: #{error.message}"
    end
  end
end
