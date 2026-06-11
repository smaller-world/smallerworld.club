# typed: strict

module Discard::Model
  sig { returns(T::Boolean) }
  def discarded?; end

  sig { returns(T::Boolean) }
  def kept?; end
end
