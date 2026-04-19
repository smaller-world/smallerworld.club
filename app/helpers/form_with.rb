# typed: true
# frozen_string_literal: true

module FormWith
  extend T::Sig
  extend T::Helpers
  include Phlex::Rails::Helpers::FormWith

  requires_ancestor { Phlex::HTML }

  # == Methods ==

  sig do
    params(
      model: T.nilable(Object),
      url: T.nilable(String),
      method: T.nilable(Symbol),
      options: T.untyped,
      block: T.proc.params(form: ActionView::Helpers::FormBuilder).void,
    ).void
  end
  def rails_form_with(model: nil, url: nil, method: nil, **options, &block)
    form_with(model:, url:, method:, **options, &block)
  end

  sig do
    params(
      model: T.nilable(Object),
      url: T.nilable(String),
      method: T.nilable(Symbol),
      options: T.untyped,
      block: T.proc.params(form: ComponentFormBuilder).void,
    ).void
  end
  def component_form_with(model: nil, url: nil, method: nil, **options, &block)
    form_with(
      builder: ComponentFormBuilder,
      model:,
      url:,
      method:,
      **options,
      &block
    )
  end
end
