# typed: true
# frozen_string_literal: true

class SendWhatsappGroupMessageJob < ApplicationJob
  # == Configuration ==

  queue_as :default

  # == Job ==

  sig { params(group: WhatsappGroup, text: String, options: T.untyped).void }
  def perform(group, text:, **options)
    tag_logger do
      logger.info("Sending message to group #{group.jid}: #{text}")
    end
    group.send_message(**T.unsafe({ text:, **options }))
  end
end
