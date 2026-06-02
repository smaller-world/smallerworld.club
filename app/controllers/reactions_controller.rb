# typed: true
# frozen_string_literal: true

class ReactionsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: :index

  # == Actions ==

  # GET /posts/:post_id/reactions
  def index
    post = find_post
    authorize!(post, to: :show?)
    respond_to do |format|
      format.html do
        render Views::Reactions::Index.new(post:)
      end if turbo_frame_request?
    end
  end

  # POST /posts/:post_id/reactions
  def create
    respond_to do |format|
      format.html do
        current_user = current_user!
        post = find_post
        authorize!(post, to: :react?)
        reaction_params = params.expect(reaction: [ :emoji ])
        reaction = post.reactions.find_or_initialize_by(
          reactor: current_user,
          **reaction_params,
        )
        if reaction.save
          redirect_to([ post, :reactions ])
        else
          render Views::Reactions::Index.new(post:, new_reaction: reaction),
            status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /reactions/:id
  def destroy
    respond_to do |format|
      format.html do
        reaction = find_reaction
        authorize!(reaction)
        reaction.destroy!
        redirect_to([ reaction.post!, :reactions ])
      rescue ActiveRecord::RecordNotFound
        head(:not_found)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Reaction) }
  def find_reaction
    Reaction.find(params.fetch(:id))
  end

  sig { returns(Post) }
  def find_post
    Post.find(params.fetch(:post_id))
  end
end
