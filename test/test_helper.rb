# typed: true
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"

# == Helpers ==

require_relative "test_helpers/downloads_test_helper"
require_relative "test_helpers/phone_number_verification_request_test_helper"
require_relative "test_helpers/session_test_helper"
require_relative "test_helpers/system_session_test_helper"
require_relative "test_helpers/world_test_helper"

module ActiveSupport
  class TestCase
    extend T::Sig

    # == Configuration ==

    # Run tests in parallel with specified workers
    parallelize workers: :number_of_processors

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical
    # order.
    fixtures :all

    # The v1 database is never used in test (it only exists for production
    # data imports). Skip transactional fixtures for it so Rails doesn't try
    # to open a connection to it during test setup, which would fail when
    # credentials are unavailable (e.g. on Dependabot CI runs).
    skip_transactional_tests_for_database :v1

    # private

    # # == Helpers ==

    # sig do
    #   type_parameters(:U).params(
    #     errors: T.any(Module, String),
    #     block: T.proc.returns(T.type_parameter(:U)),
    #   ).returns(T.type_parameter(:U))
    # end
    # def retry_on(*errors, &block)
    #   yield
    # rescue *errors
    #   retry
    # end
  end
end
