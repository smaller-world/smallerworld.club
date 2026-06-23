# typed: true
# frozen_string_literal: true

class WorldV1PostsImportsController < ApplicationController
  # == Actions ==

  # GET /world/:world_id/v1_posts_import?import_job_id=...
  def show
    respond_to do |format|
      if turbo_frame_request?
        format.html do
          world = find_world
          authorize!(world)
          import_job = if (job_id = params[:import_job_id])
            SolidQueue::Job.find(job_id)
          end
          render Views::WorldV1PostsImport::Show.new(world:, import_job:)
        end
      end
    end
  end

  # POST /world/:world_id/v1_posts_import
  def create
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        enqueued_job = world.import_v1_posts_later(limit: 20)
        redirect_to(
          [ world, :v1_posts_import, import_job_id: enqueued_job.provider_job_id ],
          status: :see_other,
        )
      end
    end
  end

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end
end
