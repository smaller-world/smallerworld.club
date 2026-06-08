# typed: strict
# frozen_string_literal: true

class Notification::Message
  include SmartProperties

  # == Properties ==

  property! :target_url,
    accepts: String,
    converts: ->(url) {
      Rails.application.routes.url_helpers.polymorphic_path(url)
    }
  property! :title, accepts: String
  property :body, accepts: String
  property :world, accepts: World
end
