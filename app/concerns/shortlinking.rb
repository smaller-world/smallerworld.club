# typed: strict
# frozen_string_literal: true

module Shortlinking
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  abstract!

  # == Interface ==

  sig { abstract.returns(T::Hash[Symbol, String]) }
  def url_options; end

  private

  # == Helpers ==

  T::Sig::WithoutRuntime.sig do
    returns(T.all(GeneratedUrlHelpersModule, GeneratedPathHelpersModule))
  end
  def shortlinked
    Smallerworld.application.shortlinked_url_helpers(url_options)
  end
end
