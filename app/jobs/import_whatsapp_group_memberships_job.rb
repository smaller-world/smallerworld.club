# typed: true
# frozen_string_literal: true

class ImportWhatsappGroupMembershipsJob < ApplicationJob
  # == Configuration ==

  queue_as :default
  limits_concurrency key: ->(group) { group }, on_conflict: :discard
  discard_on WaSenderApi::Forbidden
  retry_on WaSenderApi::RequestTimeout, wait: :polynomially_longer
  retry_on WaSenderApi::TooManyRequests, wait: :polynomially_longer

  # == Job ==

  sig { params(group: WhatsappGroup).void }
  def perform(group)
    tag_logger do
      logger.info("Importing memberships for group: #{group.jid}")
    end
    group.import_memberships
  end
end
