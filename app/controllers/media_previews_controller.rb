# typed: true
# frozen_string_literal: true

class MediaPreviewsController < ApplicationController
  # GET /media_previews/:signed_id
  def show
    signed_id = params.fetch(:signed_id)
    blob = ActiveStorage::Blob.find_signed!(signed_id)
    variant = blob.variant(resize_to_limit: [ 800, 800 ], convert: "png")
    redirect_to(rails_representation_path(variant))
  end
end
