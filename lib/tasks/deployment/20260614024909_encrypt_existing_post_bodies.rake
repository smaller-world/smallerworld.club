# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: encrypt_existing_post_bodies"
  task encrypt_existing_post_bodies: :environment do
    puts "Running deploy task 'encrypt_existing_post_bodies'"

    Post.includes(:rich_text_body).find_each do |post|
      puts "Encrypting #{post.id}..."
      post.rich_text_body&.encrypt
      post.encrypt
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create(version: AfterParty::TaskRecorder.new(__FILE__).timestamp)
  end
end
