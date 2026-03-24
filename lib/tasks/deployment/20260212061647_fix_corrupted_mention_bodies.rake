# typed: true
# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: Restore original message bodies corrupted by in-place gsub mutation"
  task fix_corrupted_mention_bodies: :environment do
    puts "Running deploy task 'fix_corrupted_mention_bodies'"

    corrupted = WhatsappMessage.where("body LIKE ?", "%@(YOURSELF)%")
    puts "Found #{corrupted.count} corrupted messages"

    corrupted.find_each do |message|
      webhook = WebhookMessage
        .where(event: "messages.upsert")
        .where("data -> 'messages' -> 'key' ->> 'id' = ?", message.whatsapp_id)
        .first

      unless webhook
        puts "  SKIP #{message.whatsapp_id}: no matching webhook message"
        next
      end

      original_body = webhook.data.dig("messages", "message", "conversation") ||
        webhook.data.dig("messages", "message", "extendedTextMessage", "text")

      unless original_body
        puts "  SKIP #{message.whatsapp_id}: no body in webhook payload"
        next
      end

      message.update_columns(body: original_body) # rubocop:disable Rails/SkipsModelValidations
      puts "  FIXED #{message.whatsapp_id}"
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create(version: AfterParty::TaskRecorder.new(__FILE__).timestamp)
  end
end
