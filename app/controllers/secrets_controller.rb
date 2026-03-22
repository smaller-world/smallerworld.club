# typed: true
# frozen_string_literal: true

class SecretsController < ApplicationController
  # == Actions ==

  # GET /secrets
  def index
    respond_to do |format|
      format.html do
        @page_title = "secrets"
      end
    end
  end

  # POST /secrets/find
  def find
    respond_to do |format|
      format.html do
        secret_location = params.expect(:secret_location)
        nearby_posts = Post.where(
          "ST_DWithin(secret_location, ST_GeomFromText(?), 1000)",
          secret_location,
        )
        @post_shares = nearby_posts.map do |post|
          PostShare.find_or_create_by!(post:, sharer: post.author!)
        end
        render :index, status: :unprocessable_content
      end
    end
  end
end
