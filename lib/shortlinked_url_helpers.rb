# typed: false
# frozen_string_literal: true


require "rails"

class ShortlinkedUrlHelpers
  extend T::Sig

  public_send(:include, Rails.application.routes.url_helpers)

  sig { params(url_options: T.untyped).void }
  def initialize(**url_options)
    @url_options = url_options
  end

  private

  sig { returns(Hash) }
  def default_url_options
    @url_options
  end
end
