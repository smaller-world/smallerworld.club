# typed: true
# frozen_string_literal: true

class MediaPreviewsController < ApplicationController
  # GET /media_previews/:signed_id
  def show
    signed_id = params.fetch(:signed_id)
    blob = ActiveStorage::Blob.find_signed!(signed_id)
    representation = if blob.content_type == "image/gif"
      blob
    else
      blob.variant(resize_to_limit: [ 512, 512 ], convert: "png")
    end
    redirect_to(rails_representation_path(representation))
  end
end
