# typed: true
# frozen_string_literal: true

module Filepond
  class FilesController < ApplicationController
    include ActiveStorage::Streaming

    # == Actions ==

    # GET /filepond/files/:signed_id
    sig { void }
    def show
      if (blob = find_blob)
        send_blob_stream(blob)
      else
        head :not_found
      end
    end


    # DELETE /filepond/files/:signed_id
    def destroy
      if (blob = find_blob)
        blob.purge
        head :ok
      else
        head :not_found
      end
    end

    private

    # == Helpers ==

    sig { returns(T.nilable(ActiveStorage::Blob)) }
    def find_blob
      ActiveStorage::Blob.find_signed(params.fetch(:signed_id))
    end
  end
end
