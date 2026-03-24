# typed: true
# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  extend T::Sig
  extend T::Helpers

  abstract!

  include UrlHelpers

  # == Configuration ==

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer
  # available
  discard_on ActiveJob::DeserializationError

  rescue_from Exception, with: :report_to_sentry

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def default_url_options
    ActionMailer::Base.default_url_options
  end

  private

  # == Helpers ==

  sig { params(exception: Exception).void }
  def report_to_sentry(exception)
    Sentry.capture_exception(exception)
    raise
  end
end
