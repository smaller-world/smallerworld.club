# typed: strict
# frozen_string_literal: true

class Components::NextPageControl < Components::Base
  include Phlex::Rails::Helpers::FormWith
  include NormalizeAttributes

  # == Initialization ==

  sig do
    params(
      target: Object,
      pagy: Pagy,
      autoclick: T::Boolean,
      id: String,
      disable_for: T.nilable(ActiveSupport::Duration),
      attributes: T.untyped,
    ).void
  end
  def initialize(
    target:,
    pagy:,
    autoclick: false,
    id: "next_page_control",
    disable_for: nil,
    **attributes
  )
    super(**attributes)
    @target = target
    @pagy = pagy
    @autoclick = autoclick
    @disable_for = disable_for
    @id = id

    @param_blocks = T.let([], T::Array[T.proc.void])
    @submit_block = T.let(nil, T.nilable(T.proc.void))
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    vanish(&content)
    form_with(
      url: url_for(@target),
      method: :get,
      namespace: @id,
      data: {
        turbo_stream: true,
      },
      html: {
        id: @id,
        **normalize_attributes(mix(
          {
            hidden: !@pagy.next,
          },
          @attributes,
        )),
      },
    ) do |form|
      if (page = @pagy.next)
        form.hidden_field(:page, value: page)
      end
      @param_blocks.each(&:call)
      if @submit_block
        @submit_block.call
      else
        submit do
          "next page"
        end
      end
    end
  end

  # == Interface ==

  sig { params(name: String, value: String).void }
  def with_param(name:, value:)
    @param_blocks << ->() {
      input(type: :hidden, name:, value:)
    }
  end

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.proc.params(button: Components::Button).returns(T.anything),
    ).void
  end
  def with_submit(variant: :secondary, size: :default, **attributes, &content)
    @submit_block = ->() {
      submit(variant:, size:, **attributes, &content)
    }
  end

  private

  # == Helpers ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.proc.params(button: Components::Button).returns(T.anything),
    ).void
  end
  def submit(variant: :default, size: :default, **attributes, &content)
    Components::Button(
      type: :submit,
      variant:,
      size:,
      **mix(button_attributes, attributes),
      &content
    )
  end

  sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def autoclick_attributes
    if @autoclick && @pagy.next
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

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def button_attributes
    mix(autoclick_attributes, disable_for_attributes)
  end
end
