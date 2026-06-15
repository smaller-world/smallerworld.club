# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: reencrypt_post_bodies_deterministic"
  task reencrypt_post_bodies_deterministic: :environment do
    puts "Running deploy task 'reencrypt_post_bodies_deterministic'"

    # Re-encrypts post bodies with the current (deterministic) scheme. The
    # `previous: { deterministic: false }` option on `Post#plain_body` lets us
    # read rows written under the old non-deterministic scheme; calling
    # `#encrypt` rewrites them under the primary scheme. `#save` would NOT do
    # this — the decrypted value is unchanged, so the attribute isn't dirty and
    # Rails skips writing it.
    failed = []
    Post.includes(:rich_text_body).find_each do |post|
      puts "Re-encrypting #{post.id}..."
      post.encrypt
      post.save!
    rescue => error
      warn("Failed to re-encrypt #{post.id}: #{error.class}: #{error.message}")
      failed << post.id
    end

    if failed.any?
      raise "Re-encryption failed for #{failed.size} post(s): " \
        "#{failed.join(", ")}"
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create(version: AfterParty::TaskRecorder.new(__FILE__).timestamp)
  end
end
