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

  def self.call(image_id:)
    new(image_id).call
  end

  def initialize(image_id)
    @image_id = image_id
  end

  def call
    return unless blob_image

    response = get_pairing

    { success?: true, payload: response }
  end

  private

  attr_reader :image_id

  def get_pairing
    begin
      response = client.messages(
        parameters: {
          model: ANTHROPIC_MODEL,
          system: prompt['system'],
          messages: prompt['messages'],
          max_tokens: 1000
        }
      )
    rescue Faraday::ClientError => e
      handle_error(e)
    end
  
    text_response = response.dig('content', 0, 'text')
    return if text_response.blank?

    parse_pairing_response(text_response)
  end

  def blob_image
    @blob_image ||= ActiveStorage::Blob.find(image_id)
  end

  def client
    @client ||= Anthropic::Client.new
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
    fields = [:name, :description, :category, :subcategory, :flavor_profiles, :primary_flavor, :price_range, :attributes, :texture]
    
    item1_values = lines[0].split('|').map(&:strip)
    item2_values = lines[1].split('|').map(&:strip)
    
    {
      item_1: Hash[fields.zip(item1_values)].merge(flavor_profiles: item1_values[4].split(',')),
      item_2: Hash[fields.zip(item2_values)].merge(flavor_profiles: item2_values[4].split(','))
    }
  rescue StandardError => e
    raise ParseError, "Failed to parse response: #{e.message}"
  end

  def handle_error(e)
    message = e.response[:body].dig('error', 'message')
    case e.response[:status]
    when 400
      raise InvalidInputError, message
    when 404
      raise NotFoundError, message
    when 429
      raise TooManyRequestsError, message
    when 529
      raise AnthropicOverloadedError, message
    else
      raise PairingServiceError, "Request failed: #{message}"
    end
  end
end
