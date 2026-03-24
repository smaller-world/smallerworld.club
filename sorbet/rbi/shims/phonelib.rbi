# typed: true
# frozen_string_literal: true

module Phonelib
  module Core
    sig { params(phone: String, passed_country: T.untyped).returns(Phone) }
    def parse(phone, passed_country = T.unsafe(nil)); end
  end
end
