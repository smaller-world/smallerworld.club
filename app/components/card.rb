# typed: strict
# frozen_string_literal: true

class Components::Card < Components::Base
  # == Configuration ==

  SIZES = [ :default, :sm ]

  # == Initialization ==

  sig { params(size: Symbol, attributes: T.untyped).void }
  def initialize(size: :default, **attributes)
    unless size.in?(SIZES)
      raise InvalidParameter.new(parameter: :size, value: size)
    end

    @size = size
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      class: "card group/card",
      data: {
        slot: "card",
        size: @size,
      },
      &content
    )
  end

  # == Interface ==

  sig { returns(Symbol) }
  attr_reader :size

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def header(**attributes, &content)
    slot(
      "card-header",
      **mix({ class: "group/card-header" }, attributes),
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**attributes, &content)
    slot("card-title", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    slot("card-description", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def action(**attributes, &content)
    slot("card-action", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def content(**attributes, &content)
    slot("card-content", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def footer(**attributes, &content)
    slot("card-footer", **attributes, &content)
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
