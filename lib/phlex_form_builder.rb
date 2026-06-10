# typed: true
# frozen_string_literal: true

require "sorbet-runtime"
require "phlex-rails"

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

  sig do
    params(
      record_name: ::Symbol,
      record_object: ::T.nilable(::Object),
      fields_options: ::T.nilable(::T::Hash[::Symbol, ::T.untyped]),
      block: ::T.proc.params(builder: ::PhlexFormBuilder).void,
    ).void
  end
  def fields_for(record_name, record_object = nil, fields_options = nil, &block)
    html = @object.fields_for(record_name, record_object, fields_options) do |builder|
      yield ::PhlexFormBuilder.new(builder, component: @component)
    end
    @component.raw(html)
  end
end
