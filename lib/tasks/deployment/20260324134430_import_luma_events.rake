# typed: true
# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: Import events from Luma"
  task import_luma_events: :environment do
    puts "Running deploy task 'import_luma_events'"

    events = Event.import_from_luma
    puts "Imported #{events.size} upcoming events from Luma"

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create(version: AfterParty::TaskRecorder.new(__FILE__).timestamp)
  end
end