# typed: strict
# frozen_string_literal: true

module Telnyx
  class Client
    sig { params(api_key: String).void }
    def initialize(api_key:); end

    sig { returns(T.untyped) }
    def messages; end
  end

  module Errors
    class BadRequestError < StandardError; end
  end
end
