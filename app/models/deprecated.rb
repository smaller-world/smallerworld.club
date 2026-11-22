# typed: strict
# frozen_string_literal: true

module Deprecated
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix
    "deprecated_"
  end
end
