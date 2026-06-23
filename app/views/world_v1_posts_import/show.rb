# typed: strict
# frozen_string_literal: true

class Views::WorldV1PostsImport::Show < Views::Base
  # == Initialization ==

  sig { params(world: World, import_job: T.nilable(SolidQueue::Job)).void }
  def initialize(world:, import_job:)
    @world = world
    @import_job = import_job
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    turbo_frame_tag(:v1_posts_import) do
      Components::WorldV1PostsImportAlert(
        world: @world,
        import_job: @import_job,
      )
    end
  end
end
