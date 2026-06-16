# typed: strict
# frozen_string_literal: true

class Notification::Message
  include SmartProperties

  # == Properties ==

  property! :target_url,
    accepts: String,
    converts: ->(url) {
      options = if url.is_a?(Array)
        if url.last.is_a?(Hash)
          url.pop
        end
      end
      Rails.application.routes.url_helpers.polymorphic_path(url, **options)
    }
  property! :title, accepts: String
  property :body, accepts: String
  property :world, accepts: World
end
