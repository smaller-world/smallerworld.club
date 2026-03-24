# typed: true
# frozen_string_literal: true

class ImportWhatsappUserMetadataJob < ApplicationJob
  # == Configuration ==

  queue_as :default
  limits_concurrency key: ->(user) { user }, on_conflict: :discard
  retry_on WaSenderApi::TooManyRequests, wait: :polynomially_longer

  # == Job ==

  sig { params(user: WhatsappUser).void }
  def perform(user)
    tag_logger do
      logger.info("Importing metadata for user: #{user.lid}")
    end
    user.import_metadata
  end
end
