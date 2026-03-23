# typed: true
# frozen_string_literal: true

class SecretsController < ApplicationController
  # == Actions ==

  # GET /secrets[?near=]
  def index
    respond_to do |format|
      format.html do
        @page_title = "secrets"
        if (near = params[:near])
          @post_shares = nearby_posts_shares(near)
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(location: String).returns(T::Enumerable[PostShare]) }
  def nearby_posts_shares(location)
    posts = Post.where(
      "ST_DWithin(secret_location, ST_GeomFromText(?), 1000)",
      location,
    )
    posts.map do |post|
      PostShare.find_or_create_by!(post:, sharer: post.author!)
    end
  end
end
