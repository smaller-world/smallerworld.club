# typed: true
# frozen_string_literal: true

class PathConfigurationsController < PublicController
  # == Actions ==

  # GET /path_configurations/:id(.json)
  def show
    respond_to do |format|
      format.json do
        id = params.fetch(:id)
        path = Rails.root.join("config/path_configurations/#{id}.json")
        send_file(path)
      end
    end
  end
end
