# typed: true
# frozen_string_literal: true

class PostReactionsController < ApplicationController
  # == Filters ==

  before_action :require_authentication!, only: %i[create destroy]

  # == Actions ==

  # GET /posts/:post_id/reactions
  def index
    @post = find_post(scope: Post.with_reactions)
    respond_to do |format|
      format.json do
        reactions = authorized_scope(@post.reactions)
        render(json: {
          reactions: PostReactionSerializer.many(reactions),
        })
      end
    end
  end

  # POST /posts/:post_id/reactions?friend_token=...
  def create
    reactor = require_authentication!
    @post = find_post
    respond_to do |format|
      format.json do
        reaction_params = params.expect(reaction: [ :emoji ])
        reaction = @post.reactions.find_or_create_by!(
          reactor:,
          **reaction_params,
        )
        render(
          json: {
            reaction: PostReactionSerializer.one(reaction),
          },
          status: :created,
        )
      end
      format.turbo_stream do
        reaction_params = params.expect(post_reaction: [ :emoji ])
        @reaction = @post.reactions
          .find_or_create_by(reactor:, **reaction_params)
        unless @reaction.persisted?
          flash.now[:alert] = @reaction.errors.full_messages.first!
        end
        # if @reaction.save
        #   redirect_to(post_reactions_path(@post), status: :see_other)
        # else
        #   flash.now[:alert] = @reaction.errors.full_messages.first
        #   render(turbo_stream: turbo_stream.replace(
        #     "flash",
        #     partial: "layouts/flash",
        #   ))
        # end
      end
    end
  end

  # DELETE /post_reactions/:id
  def destroy
    respond_to do |format|
      format.json do
        reaction = find_reaction!
        authorize!(reaction)
        reaction.destroy!
        render(json: { "postId": reaction.post_id })
      end
    end
  end

  private

  # == Helpers ==

  sig { params(scope: Post::PrivateRelation).returns(Post) }
  def find_post(scope: Post.all)
    scope.find(params.fetch(:post_id))
  end

  sig { params(scope: PostReaction::PrivateRelation).returns(PostReaction) }
  def find_reaction!(scope: PostReaction.all)
    scope.find(params.fetch(:id))
  end
end
