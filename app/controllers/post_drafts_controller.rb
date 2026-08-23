# typed: true
# frozen_string_literal: true

class PostDraftsController < ApplicationController
  # == Actions ==

  # POST /worlds/:world_id/post_draft/restore
  def restore
    respond_to do |format|
      format.turbo_stream do
        world = find_world
        post_params = params.expect(post: [
          :type_id, :emoji, :title, :body, :quiet, images: [],
        ])
        authorize!(world, to: :manage?)
        post = world.posts.build(**post_params)
        render turbo_stream: replace_post_form(post:)
      end
    end
  end

  private

  # == Helpers ==

  sig { params(scope: World::PrivateRelation).returns(World) }
  def find_world(scope: World.all)
    scope.friendly.find(params.fetch(:world_id))
  end

  sig { params(post: Post).returns(ActiveSupport::SafeBuffer) }
  def replace_post_form(post:)
    turbo_stream.replace(
      :post_form,
      renderable: Components::PostForm.new(post:),
    )
  end

  # == Callbacks ==
  sig { params(error: ActionPolicy::Unauthorized).void }
  def head_unauthorized(error)
    head(:unauthorized)
  end
end
