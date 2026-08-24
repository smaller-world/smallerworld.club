# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: coalesce_ios_app_on_mac_platform_to_ios"
  task coalesce_ios_app_on_mac_platform_to_ios: :environment do
    puts "Running deploy task 'coalesce_ios_app_on_mac_platform_to_ios'"

    # Put your task implementation HERE.
    updated_count = Device.where(platform: "ios-app-on-mac").update_all(platform: "ios") # rubocop:disable Rails/SkipsModelValidations
    puts "Coalesced ios_app_on_mac -> ios on #{updated_count} devices"

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create(version: AfterParty::TaskRecorder.new(__FILE__).timestamp)
  end
end
