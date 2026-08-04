# typed: strict
# frozen_string_literal: true

class Components::Field < Components::Base
  # == Configuration ==

  ORIENTATIONS = [ :vertical, :horizontal, :responsive ]

  # == Initialization ==

  sig do
    params(
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    orientation: :vertical,
    invalid: false,
    **attributes
  )
    unless orientation.in?(ORIENTATIONS)
      raise InvalidParameter.new(parameter: :orientation, value: orientation)
    end

    super(**attributes)
    @orientation = orientation
    @invalid = invalid
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :div,
      role: "group",
      class: "field group/field",
      data: {
        slot: "field",
        orientation: @orientation,
        invalid: ("true" if @invalid),
      },
      &content
    )
  end

  # == Interface ==

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def content(**attributes, &content)
    div(
      **mix(
        {
          class: "field-content group/field-content",
          data: {
            slot: "field-content",
          },
        },
        attributes,
      ),
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def label(**attributes, &content)
    render Components::FieldLabel.new(**attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def title(**attributes, &content)
    div(
      **mix(
        {
          class: "field-title",
          data: {
            slot: "field-title",
          },
        },
        attributes,
      ),
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.returns(T.anything))).void }
  def description(**attributes, &content)
    p(
      **mix(
        {
          class: "field-description",
          data: {
            slot: "field-description",
          },
        },
        attributes,
      ),
      &content
    )
  end

  sig do
    params(
      messages: T.nilable(T::Array[String]),
      attributes: T.untyped,
      content: T.nilable(
        T.proc.params(field_error: Components::FieldError).returns(T.anything),
      ),
    ).void
  end
  def error(messages: nil, **attributes, &content)
    Components::FieldError(messages:, **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def separator(**attributes, &content)
    div(
      **mix(
        {
          class: "field-separator",
          data: {
            slot: "field-separator",
            content: block_given?,
          },
        },
        attributes,
      ),
    ) do
      Components::Separator(class: "absolute inset-0 top-1/2")
      if block_given?
        span(
          class: "field-separator-content", data: {
            slot: "field-separator-content",
          },
          &content
        )
      end
    end
  end
end
