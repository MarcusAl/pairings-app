class PairingJob < ActiveJob::Base
  class PairingJobError < StandardError; end

  WAIT_TIME = 5.seconds

  queue_as :default

  def perform(item, user)
    return unless item.image.attached?

    blob_image = item.image.blob

    response = PairingService.call(blob_image_id: blob_image.id)

    return unless response[:success?]

    ActiveRecord::Base.transaction do
      Rails.logger.debug "Starting transaction"
      item.update!(
        response.dig(:payload, :item1).slice(*Item::FIELDS)
      )

      Rails.logger.debug "After update! - This line should never be reached if update! fails"

      
      item2 = Item.create!(
        response.dig(:payload, :item2)
          .slice(*Item::FIELDS)
          .merge(user: user)
      )
      
      Pairing.create!(
        item1: item, 
        item2: item2, 
        user: user, 
        confidence_score: response.dig(:payload, :pairing, :confidence_score), 
        ai_reasoning: response.dig(:payload, :pairing, :ai_reasoning), 
        pairing_notes: response.dig(:payload, :pairing, :pairing_notes), 
        strength: response.dig(:payload, :pairing, :strength)
      )

      AttachImageJob.set(wait: WAIT_TIME).perform_later(item2, response.dig(:payload, :image_url))
    end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create pairing: #{e.message}"
      raise PairingJobError, e.message
  end
end
