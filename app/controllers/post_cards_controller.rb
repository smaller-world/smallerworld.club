# typed: true
# frozen_string_literal: true

class PostCardsController < ApplicationController
  # == Filters ==

  rescue_from ActionPolicy::Unauthorized, with: :head_unauthorized

  # == Actions ==

  # GET /posts/:post_id/card
  def show
    respond_to do |format|
      if turbo_frame_request?
        format.html do
          current_user = Current.user!
          post = find_post(scope: Post.includes(:reactions))
          authorize!(post)
          replied = post.reply_initiations.exists?(replier: current_user)
          render Views::PostCards::Show.new(post:, replied:)
        end
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
