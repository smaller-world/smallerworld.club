# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: world_card_version_2"
  task world_card_version_2: :environment do
    puts "Running deploy task 'world_card_version_2'"

    # Put your task implementation HERE.
    WorldCard.find_each(&:trigger_pass_update_later)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create(version: AfterParty::TaskRecorder.new(__FILE__).timestamp)
  end
end
