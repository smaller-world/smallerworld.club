# typed: strict
# frozen_string_literal: true

class Components::FieldLabel < Components::Base
  include Phlex::Rails::Helpers::LabelTag

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      id: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, id: nil, **attributes)
    super(**attributes)
    @id = id
    @form = form
    @field = field
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    content_html = if content
      capture(&content)
    end
    attributes = mix(
      {
        id: @id,
        class: "field-label group/field-label peer/field-label",
        data: {
          slot: "field-label",
        },
      },
      **@attributes,
    )

    if @form && @field
      @form.label(@field, **attributes) do
        if content_html
          raw(content_html) # rubocop:disable Rails/OutputSafety
        elsif (object_class = @form.object&.class) &&
            object_class.is_a?(ActiveModel::Translation)
          object_class.human_attribute_name(@field)
        else
          @field.to_s.humanize
        end
      end
    else
      label_tag(@field, **attributes, &content)
    end
  end

  # == Interface ==

  sig do
    params(
      id: T.nilable(String),
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(field: Components::Field).void,
    ).void
  end
  def field(
    id: nil,
    orientation: :vertical,
    invalid: false,
    **attributes,
    &content
  )
    render Components::Field.new(
      form: @form,
      field: @field,
      id:,
      orientation:,
      invalid:,
      **attributes,
      &content
    )
  end

  sig { returns(String) }
  def id
    @id ||= if @form && @field
      @form.field_id(@field, :label)
    elsif @field
      field_id(@field, :label)
    else
      SecureRandom.uuid
    end
  end
end
