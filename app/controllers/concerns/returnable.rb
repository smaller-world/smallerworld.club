# typed: strict
# frozen_string_literal: true

module Returnable
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionController::Base }

  private

  # == Helpers ==

  sig { params(parameter: Symbol).returns(T.nilable(String)) }
  def return_url(parameter = :return_to)
    url = params[parameter]
    if url.is_a?(String) && url.start_with?("/") && !url.start_with?("//")
      url_from(url)
    end
  end
end
