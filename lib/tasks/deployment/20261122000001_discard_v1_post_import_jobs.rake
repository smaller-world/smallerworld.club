# frozen_string_literal: true

namespace :after_party do
  desc "Discard unfinished V1 post import jobs"
  task discard_v1_post_import_jobs: :environment do
    imports = SolidQueue::Job.where(
      class_name: [ "ImportV1PostsJob", "Deprecated::ImportV1PostsJob" ],
      finished_at: nil,
    )

    # Run with legacy enqueues and workers stopped. A claimed execution may still be writing posts.
    SolidQueue::Job.transaction do
      if SolidQueue::ClaimedExecution.exists?(job_id: imports.select(:id))
        raise "V1 post imports are still claimed. Quiesce enqueues and workers before retrying."
      end

      imports.find_each(&:discard)
      raise "Unfinished V1 post import jobs remain" if imports.exists?
    end

    AfterParty::TaskRecord
      .create!(version: AfterParty::TaskRecorder.new(__FILE__).timestamp)
  end
end
