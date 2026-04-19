# typed: true
# frozen_string_literal: true

class Components::Base < Phlex::HTML
  extend T::Sig
  extend T::Helpers

  abstract!

  # == View Helpers ==

  include Phlex::Rails::Helpers::ClassNames
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::TurboStreamFrom
  include PhlexIcons
  include FormWith
  include ButtonTo
  include ButtonBackTo

  register_output_helper :local_time
  register_output_helper :inline_svg_tag
  register_value_helper :auto_link
  register_value_helper :authenticated?

  # == Configuration ==

  sig { params(element: T.nilable(Symbol), attributes: T.untyped).void }
  def initialize(element: nil, **attributes)
    super()
    @element = element
    @attributes = attributes
  end

  # == Component ==

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  sig { overridable.void }
  def view_template; end

  private

  # == Helpers ==

  sig do
    params(
      default_element: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def root_element(default_element, **attributes, &content)
    public_send(
      @element || default_element,
      **mix(attributes, @attributes),
      &content
    )
  end

  sig do
    params(hash: T::Hash[Symbol, T.untyped], keys: Symbol)
      .returns(T::Hash[Symbol, T.untyped])
  end
  def delete_from(hash, *keys)
    removed_values = {}
    keys.each do |key|
      removed_values[key] = hash.delete(key) if hash.key?(key)
    end
    removed_values
  end
end
