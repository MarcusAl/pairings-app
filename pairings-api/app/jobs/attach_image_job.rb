class AttachImageJob < ApplicationJob
  queue_as :default
  retry_on OpenURI::HTTPError, SocketError, Net::OpenTimeout, attempts: 3, wait: 5.seconds

  def perform(item, image_url)
    item.attach_image_from_url(image_url)
  end
end
