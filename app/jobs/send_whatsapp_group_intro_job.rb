# typed: true
# frozen_string_literal: true

class SendWhatsappGroupIntroJob < ApplicationJob
  # == Configuration ==

  queue_as :default

  # == Job ==

  sig { params(group: WhatsappGroup).void }
  def perform(group)
    tag_logger do
      logger.info("Sending intro to group: #{group.jid}")
    end
    group.send_intro unless group.intro_sent?
  end
end
