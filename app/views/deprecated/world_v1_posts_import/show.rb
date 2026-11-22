# typed: strict
# frozen_string_literal: true

class Views::Deprecated::WorldV1PostsImport::Show < Views::Base
  # == Initialization ==

  sig { params(world: World, import_job: T.nilable(SolidQueue::Job)).void }
  def initialize(world:, import_job:)
    super()
    @world = world
    @import_job = import_job
  end

  # == View ==

  sig { override.void }
  def view_template
    turbo_frame_tag(:v1_posts_import) do
      render Components::Deprecated::WorldV1PostsImportAlert.new(
        world: @world,
        import_job: @import_job,
      )
    end
  end
end
