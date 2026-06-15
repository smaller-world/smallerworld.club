# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: encrypt_post_titles"
  task encrypt_post_titles: :environment do
    puts "Running deploy task 'encrypt_post_titles'"

    # Put your task implementation HERE.
    failed = []
    Post.includes(:rich_text_body).find_each do |post|
      puts "Re-encrypting #{post.id}..."
      post.send(:set_plain_body)
      post.encrypt
      post.save!
    rescue => error
      warn("Failed to re-encrypt #{post.id}: #{error.class}: #{error.message}")
      failed << post.id
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create(version: AfterParty::TaskRecorder.new(__FILE__).timestamp)
  end
end
