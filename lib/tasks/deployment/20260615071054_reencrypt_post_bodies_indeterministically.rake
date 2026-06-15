# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: reencrypt_post_bodies_indeterministically"
  task reencrypt_post_bodies_indeterministically: :environment do
    puts "Running deploy task 'reencrypt_post_bodies_indeterministically'"

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
