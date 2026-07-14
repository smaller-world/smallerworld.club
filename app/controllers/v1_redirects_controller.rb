# typed: true
# frozen_string_literal: true

class V1RedirectsController < PublicController
  # Redirects any URL as-is to V1.
  def redirect
    root_url = Addressable::URI.parse(Smallerworld.application.v1_url)
    root_url.path = request.path
    root_url.query_values = request.query_parameters
    redirect_to(root_url.to_s, allow_other_host: true)
  end
end
