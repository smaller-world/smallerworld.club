# typed: true
# frozen_string_literal: true

class PostDraftsController < ApplicationController
  # == Actions ==

  # POST /post_draft/restore
  def restore
    respond_to do |format|
      format.turbo_stream do
        post_params = params.expect(post: [
          :type_id, :emoji, :title, :body, :quiet, images: [],
        ])
        post_type = PostType.find(post_params.fetch(:type_id))
        authorize!(post_type, to: :show?)
        post = post_type.posts.build(**post_params)
        render turbo_stream: turbo_stream.replace(
          :post_form,
          renderable: Components::PostForm.new(post:),
        )
      end
    end
  end

  private

  # == Helpers ==

  sig { params(scope: Post::PrivateRelation).returns(Post) }
  def find_post(scope: Post.all)
    scope.find(params.fetch(:post_id))
  end

  # == Callbacks ==
  sig { params(error: ActionPolicy::Unauthorized).void }
  def head_unauthorized(error)
    head(:unauthorized)
  end
end
