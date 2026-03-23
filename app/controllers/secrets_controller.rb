# typed: true
# frozen_string_literal: true

class SecretsController < ApplicationController
  # == Actions ==

  # GET /secrets[?near=&emulate_os=]
  def index
    respond_to do |format|
      format.html do
        @page_title = "nearby secrets"
        device = DeviceDetector.new(request.user_agent)
        @os_name = params[:emulate_os] || device.os_name
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
