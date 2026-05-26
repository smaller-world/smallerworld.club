# typed: strict
# frozen_string_literal: true

class Components::Alert < Components::Base
  # == Configuration ==

  VARIANTS = [ :default, :destructive ]

  # == Initialization ==

  sig { params(variant: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, **attributes)
    unless variant.in?(VARIANTS)
      raise InvalidParameter.new(parameter: :variant, value: variant)
    end

    @variant = variant
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      role: "alert",
      class: "alert group/alert",
      data: {
        slot: "alert",
        variant: @variant,
      },
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**attributes, &content)
    slot("alert-title", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    slot("alert-description", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def action(**attributes, &content)
    slot("alert-action", **attributes, &content)
  end

  private

  # == Helpers ==

  sig do
    params(
      name: String,
      element: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def slot(name, element: :div, **attributes, &content)
    public_send(
      element,
      **mix(
        {
          class: name,
          data: {
            slot: name,
          },
        },
        attributes,
      ),
      &content
    )
  end
end
