# typed: true
# frozen_string_literal: true

# A wrapper for Phlex::Rails::Builder that enables us to add distinct
# type declarations corresponding to ActionView::Helpers::FormBuilder.
class PhlexFormBuilder < Phlex::Rails::Builder
  extend ::T::Sig

  sig do
    params(builder: ::Phlex::Rails::Builder, component: ::T.untyped)
      .returns(::T.attached_class)
  end
  def self.from(builder, component:)
    object = builder.unwrap
    new(object, component:)
  end
end
