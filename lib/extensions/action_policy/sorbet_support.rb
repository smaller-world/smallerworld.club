# typed: false # rubocop:disable Sorbet/TrueSigil
# frozen_string_literal: true

require "action_policy"

module ActionPolicy::Policy::Aliases::ClassMethods
  # Lets policies declare `sig`s with runtime checks.
  #
  # `sig` is two-phase: the block is stashed in a process-global slot, and the
  # next `method_added` claims it and wraps the method. Action Policy defines
  # `method_added` to invalidate its alias cache and doesn't call `super`, so
  # sorbet's hook never runs and the declaration is left pending — to be claimed
  # by whatever method is defined next, or to blow up the next `sig` with "You
  # called sig twice without declaring a method in between".
  #
  # `extend T::Sig` usually inserts sorbet's hook above Action Policy's, which
  # hides the problem. Tapioca does `Module.include(T::Sig)` before loading the
  # app, which makes that `extend` a no-op, and the sig leaks.
  #
  # Running the hook ourselves ahead of Action Policy's fixes the order in both
  # cases. Doing it twice is harmless: the second call finds nothing pending.
  module SorbetSupport
    def method_added(name)
      T::Private::Methods._on_method_added(self, self, name)
      super
    end
  end
  prepend SorbetSupport
end
