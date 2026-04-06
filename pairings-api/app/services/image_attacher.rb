class ImageAttacher
  class DownloadError < StandardError; end
  class AttachmentError < StandardError; end

  def self.call(record, url)
    new(record, url).call
  end

  def initialize(record, url)
    @record = record
    @url = url
  end

  def call
    return if @url.blank?

    downloaded = download
    attach(downloaded)
  end

  private

  def download
    require 'open-uri'
    URI.parse(@url).open
  rescue OpenURI::HTTPError => e
    raise DownloadError, "HTTP error downloading image (#{e.message})"
  rescue URI::InvalidURIError => e
    raise DownloadError, "Invalid URL format (#{e.message})"
  end

  def attach(downloaded)
    content_type = downloaded.content_type
    extension = content_type == 'image/png' ? '.png' : '.jpg'

    @record.image.attach(
      io: downloaded,
      filename: "item_#{@record.id}_#{Time.current.to_i}#{extension}",
      content_type: content_type,
      identify: true
    )
  rescue ActiveStorage::IntegrityError => e
    raise AttachmentError, "File integrity error (#{e.message})"
  end
end
