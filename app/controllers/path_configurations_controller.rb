# typed: true
# frozen_string_literal: true

class PathConfigurationsController < PublicController
  # == Actions ==

  # GET /path_configurations/:id(.json)
  def show
    respond_to do |format|
      format.json do
        id = params.fetch(:id)
        path = path_configurations_dir.join("#{id}.json")
        unless path.file?
          raise ActionController::RoutingError, "Not found"
        end

        send_file(path)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Pathname) }
  def path_configurations_dir
    Rails.root.join("config/path_configurations")
  end
end
