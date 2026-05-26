# typed: strict
# frozen_string_literal: true

module FormWith
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::HTML }

  include Phlex::Rails::Helpers::FormWith

  # == Helper ==

  sig do
    params(
      args: T.untyped,
      kwargs: T.untyped,
      block: T.proc.params(form: PhlexFormBuilder).void,
    ).void
  end
  def form_with(*args, **kwargs, &block)
    super(*T.unsafe(args), **kwargs) do |form|
      builder = PhlexFormBuilder.from(form, component: self)
      yield(builder)
    end
  end
end
