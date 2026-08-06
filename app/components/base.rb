# typed: strict
# frozen_string_literal: true

class Components::Base < Phlex::HTML
  extend T::Sig
  extend T::Helpers

  abstract!

  # == Helpers ==

  include Phlex::Rails::Helpers::ClassNames
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::TurboStreamFrom
  include Phlex::Rails::Helpers::DOMID

  include PhlexIcons

  include CompactMixing
  include ButtonBackTo
  include ButtonLinkTo
  include TurnstileTag
  include TokenList

  register_output_helper :local_time
  register_output_helper :inline_svg_tag
  register_value_helper :auto_link
  register_value_helper :authenticated?
  register_value_helper :allowed_to?
  register_value_helper :authorized_scope
  register_value_helper :hotwire_native_platform
  register_value_helper :hotwire_native_app?
  register_value_helper :hotwire_native_ios?
  register_value_helper :hotwire_native_ios_app_on_mac?
  register_value_helper :ios_browser?
  register_value_helper :android_browser?

  # == Errors ==

  class InvalidParameter < ArgumentError
    extend T::Sig

    sig { params(parameter: Symbol, value: T.untyped).void }
    def initialize(parameter:, value:)
      super("Invalid #{parameter}: #{value.inspect}")
      @parameter = parameter
      @value = value
    end

    sig { returns(Symbol) }
    attr_reader :parameter

    sig { returns(Symbol) }
    attr_reader :value
  end

  # == Initialization ==

  sig { params(attributes: T.untyped).void }
  def initialize(**attributes)
    super()
    @attributes = attributes
  end

  # == Component ==

  if Rails.env.development?
    sig { void }
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end

    sig { void }
    def after_template
      super
      comment { "After #{self.class.name}" }
    end
  end

  sig { overridable.void }
  def view_template; end

  private

  # == Helpers ==

  sig do
    params(
      element: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def root_element(element, **attributes, &content)
    public_send(element, **mix(attributes, @attributes), &content)
  end

  sig { returns(UrlHelpers) }
  def shortlinked_url_helpers
    SmallerWorld.application.shortlinked_url_helpers(url_options)
  end

  # sig do
  #   params(hash: T::Hash[Symbol, T.untyped], keys: Symbol)
  #     .returns(T::Hash[Symbol, T.untyped])
  # end
  # def delete_from(hash, *keys)
  #   removed_values = {}
  #   keys.each do |key|
  #     removed_values[key] = hash.delete(key) if hash.key?(key)
  #   end
  #   removed_values
  # end
end
