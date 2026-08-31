# typed: strict
# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  extend T::Sig
  extend T::Helpers

  abstract!

  # include UrlHelpers

  # == Configuration ==

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer
  # available
  discard_on ActiveJob::DeserializationError

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def default_url_options
    ActionMailer::Base.default_url_options
  end
end
