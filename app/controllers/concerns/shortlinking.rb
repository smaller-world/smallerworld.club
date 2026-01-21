# typed: true
# frozen_string_literal: true

module Shortlinking
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ApplicationController }

  private

  # == Helpers ==

  T::Sig::WithoutRuntime.sig do
    returns(T.all(GeneratedUrlHelpersModule, GeneratedPathHelpersModule))
  end
  def shortlinked
    Rails.application.shortlinked_url_helpers(url_options)
  end
end
