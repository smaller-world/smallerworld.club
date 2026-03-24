# typed: true
# frozen_string_literal: true

class Components::PaginationButton < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  # == Configuration ==

  sig do
    params(
      to: T.untyped,
      pagy: T.nilable(Pagy),
      variant: Symbol,
      size: Symbol,
      form_class: T.nilable(String),
      form: T::Hash[Symbol, T.untyped],
      disable_for: T.nilable(ActiveSupport::Duration),
      options: T.untyped,
    ).void
  end
  def initialize(
    to:,
    pagy: nil,
    variant: :default,
    size: :default,
    form_class: nil,
    form: {},
    disable_for: nil,
    **options
  )
    super()
    @to = to
    @pagy = pagy
    @variant = variant
    @size = size
    @form_options = T.let(
      mix(form, { class: form_class }),
      T::Hash[Symbol, T.untyped],
    )
    @disable_for = disable_for
    @options = options
  end

  # == Component ==

  sig { override(allow_incompatible: true).params(content: T.proc.void).void }
  def view_template(&content)
    enable_after_value = if (disable_for = @disable_for)
      disable_for.to_i * 1000
    end
    button_to(
      @to,
      mix(
        {
          form: mix(
            {
              id: "pagination",
              class: "pagination_button",
              data: {
                turbo_stream: true,
              },
            },
            @form_options,
          ),
          params: {
            page: @pagy&.next,
          }.compact,
          class: "group/button",
          disabled: @disable_for.present?,
          data: {
            slot: "button",
            variant: @variant,
            size: @size,
            controller: class_names(
              "intersection click",
              "disabled" => @disable_for.present?,
            ),
            action: "intersection:appear->click#click",
            disabled_enable_after_value: enable_after_value,
          },
        },
        @options,
      ),
      &content
    )
  end
end
