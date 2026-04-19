# typed: true
# frozen_string_literal: true

class Components::Field < Components::Base
  sig do
    params(
      form: T.nilable(Phlex::Rails::Builder),
      field: T.nilable(Symbol),
      orientation: Symbol,
      invalid: T.nilable(TrueClass),
      options: T.untyped,
    ).void
  end
  def initialize(
    form: nil,
    field: nil,
    orientation: :vertical,
    invalid: nil,
    **options
  )
    super(**options)
    @form = form
    @field = field
    @orientation = orientation
    @invalid = invalid
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    data = {
      slot: "field",
      orientation: @orientation,
    }
    if invalid?
      data[:invalid] = true
    end
    root_element(:div, role: "group", class: "group/field", data:, &content)
  end

  # == Interface ==

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def content(**attributes, &content)
    div_with_slot(
      "field-content",
      **mix({ class: "group/field-content" }, **attributes),
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def label(**attributes, &content)
    attributes = mix(
      {
        class: "group/field-label peer/field-label",
        data: { slot: "field-label" },
      },
      **attributes,
    )
    if (form = @form) && (field = @field)
      form.label(field, **attributes) do
        if block_given?
          yield
        elsif (record = form.object) && record.class.respond_to?(:human_attribute_name)
          record.class.human_attribute_name(field)
        else
          field.to_s.humanize
        end
      end
    else
      super(**attributes, &content)
    end
  end

  sig { params(options: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**options, &content)
    div_with_slot("field-title", **options, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    p(**mix({ data: { slot: "field-description" } }, **attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def separator(**attributes, &content)
    div_with_slot(
      "field-separator",
      **mix({ data: { content: block_given? } }, **attributes),
    ) do
      Components::Separator(class: "absolute inset-0 top-1/2")
      if block_given?
        span(data: { slot: "field-separator-content" }, &content)
      end
    end
  end

  sig do
    params(
      errors: T.nilable(T::Array[String]),
      options: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def error(errors: error_messages, **options, &content)
    return if content.nil? && errors.blank?

    div(role: "alert", data: { slot: "field-error" }, **options) do
      if block_given?
        yield
      elsif (errors = errors.presence)
        if errors.length == 1
          errors.first
        else
          ul(class: "ml-4 flex list-disc flex-col gap-1") do
            errors.each do |msg|
              li { msg }
            end
          end
        end
      end
    end
  end

  sig { returns(T.nilable(String)) }
  def id
    if (form = @form) && (field = @field)
      form.field_id(field)
    end
  end

  sig do
    params(
      attributes: T.untyped,
      block: T.nilable(T.proc.params(component: Components::Input).void),
    ).void
  end
  def input(**attributes, &block)
    render Components::Input.new(
      form: @form,
      field: @field,
      **attributes,
      &block
    )
  end

  sig do
    params(
      attributes: T.untyped,
      block: T.nilable(T.proc.params(component: Components::Input).void),
    ).void
  end
  def text_input(**attributes, &block)
    input(type: :text, **attributes, &block)
  end

  sig do
    params(
      direct_upload: T::Boolean,
      attributes: T.untyped,
      block: T.nilable(T.proc.params(component: Components::Input).void),
    ).void
  end
  def file_input(direct_upload: false, **attributes, &block)
    if direct_upload
      attributes = mix(
        { data: { direct_upload_url: rails_direct_uploads_path } },
        attributes,
      )
    end
    input(type: :file, **attributes, &block)
  end

  private

  # == Helpers ==

  sig do
    params(
      slot: String,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def div_with_slot(slot, **attributes, &content)
    div(**mix({ data: { slot: } }, **attributes), &content)
  end

  sig { returns(T.nilable(T::Array[String])) }
  def error_messages
    if (record = @form&.send(:object)) && (field = @field)
      record.errors.messages_for(field)
    end
  end

  sig { returns(T::Boolean) }
  def invalid?
    @invalid || error_messages.present?
  end
end
