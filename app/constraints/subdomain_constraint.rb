# typed: true
# frozen_string_literal: true

module SubdomainConstraint
  extend T::Sig

  # The app is now served from old.smallerworld.club, so its own subdomain must
  # not be folded onto the (now foreign) apex. Only strip other subdomains.
  sig { params(request: ActionDispatch::Request).returns(T::Boolean) }
  def self.matches?(request)
    Rails.env.production? && request.subdomain.present? &&
      request.subdomain != "old"
  end
end
