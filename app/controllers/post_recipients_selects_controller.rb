# typed: true
# frozen_string_literal: true

class PostRecipientsSelectsController < ApplicationController
  # == Actions ==

  # GET /post_types/:post_type_id/post_recipients_select
  def show
    respond_to do |format|
      if turbo_frame_request?
        format.html do
          post_type = find_post_type
          authorize!(post_type, to: :manage?)
          render Views::PostRecipientsSelects::Show.new(post_type:)
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(PostType) }
  def find_post_type
    PostType.find(params.fetch(:post_type_id))
  end
end
