# typed: strict
# frozen_string_literal: true

class Components::NextPageControl < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  # == Initialization ==

  sig do
    params(
      target: Object,
      pagy: T.nilable(Pagy),
      autoclick: T::Boolean,
      disable_for: T.nilable(ActiveSupport::Duration),
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    target:,
    pagy:,
    autoclick: false,
    disable_for: nil,
    variant: :secondary,
    size: :default,
    **attributes
  )
    super()
    @target = target
    @pagy = pagy
    @autoclick = autoclick
    @variant = variant
    @size = size
    @disable_for = disable_for
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    button_to(
      @target,
      compact_mix(
        Components::Button.root_attributes(variant: @variant, size: @size),
        {
          form: {
            id: "next_page_control",
            data: {
              turbo_stream: true,
            },
          },
          method: :get,
        },
        page_attributes,
        autoclick_attributes,
        disable_for_attributes,
        @attributes,
      ),
      &content
    )
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def page_attributes
    if (page = @pagy&.next)
      { params: { page: } }
    end
  end

  sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def autoclick_attributes
    if @autoclick
      {
        data: {
          controller: "intersection click",
          action: "intersection:appear->click#click",
        },
      }
    end
  end

  sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def disable_for_attributes
    if @disable_for
      {
        disabled: @disable_for.present?,
        data: {
          controller: "disabled",
          disabled_enable_after_value: @disable_for.to_i * 1000,
        },
      }
    end
  end
end
