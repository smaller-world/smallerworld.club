# typed: true
# frozen_string_literal: true

# The `Views::Base` is an abstract class for all your views.

# By default, it inherits from `Components::Base`, but you
# can change that to `Phlex::HTML` if you want to keep views and
# components independent.
class Views::Base < Components::Base
  extend T::Sig
  extend T::Helpers

  abstract!

  # == Configuration ==

  sig { void }
  def initialize
    # Don't pass anything to `super()`
    super()
  end

  # == Caching ==

  # More caching options at https://www.phlex.fun/components/caching
  def cache_store = Rails.cache
end
