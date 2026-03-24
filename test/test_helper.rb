# typed: true
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    extend T::Sig

    # == Configuration ==

    # Run tests in parallel with specified workers
    parallelize workers: :number_of_processors

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical
    # order.
    fixtures :all

    private

    # == Helpers ==

    sig do
      type_parameters(:U).params(
        errors: T.any(Module, String),
        block: T.proc.returns(T.type_parameter(:U)),
      ).returns(T.type_parameter(:U))
    end
    def retry_on(*errors, &block)
      yield
    rescue *errors
      retry
    end
  end
end
