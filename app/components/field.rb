# typed: true
# frozen_string_literal: true

class Components::Field < Components::Base
  # == Configuration ==

  ORIENTATIONS = [ :vertical, :horizontal, :responsive ]

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    form: nil,
    field: nil,
    orientation: :vertical,
    invalid: false,
    **attributes
  )
    unless orientation.in?(ORIENTATIONS)
      raise InvalidParameter.new(parameter: :orientation, value: orientation)
    end

    @form = form
    @field = field
    @orientation = orientation
    @force_invalid = invalid
    super(**attributes)
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
    root_element(
      :div,
      **mix({ class: "group/field", role: "group", data: }),
      &content
    )
  end

  # == Interface ==

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def content(**attributes, &content)
    div_with_slot(
      "field-content",
      **mix({ class: "group/field-content" }, attributes),
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
    if @form && @field
      html = @form.label(@field, **attributes) do
        if block_given?
          yield
        elsif (object_class = @form.object&.class) &&
            object_class.is_a?(ActiveModel::Translation)
          object_class.human_attribute_name(@field)
        else
          @field.to_s.humanize
        end
      end
      raw(html) # rubocop:disable Rails/OutputSafety
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
    if @form && @field
      @form.field_id(@field)
    end
  end

  sig do
    params(
      attributes: T.untyped,
      block: T.nilable(T.proc.params(group: Components::InputGroup).void),
    ).void
  end
  def input_group(**attributes, &block)
    Components::InputGroup(form: @form, field: @field, **attributes, &block)
  end

  sig { params(attributes: T.untyped).void }
  def input(**attributes)
    Components::Input(form: @form, field: @field, **attributes)
  end

  sig { params(attributes: T.untyped).void }
  def text_input(**attributes)
    input(type: :text, **attributes)
  end

  sig do
    params(
      value: T.nilable(T.any(ActiveStorage::Blob, ActiveStorage::Attachment)),
      direct_upload: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def file_input(
    value: nil,
    direct_upload: true,
    **attributes
  )
    Components::FileInput(
      form: @form,
      field: @field,
      value:,
      direct_upload:,
      **attributes,
    )
  end

  sig do
    params(
      value: T.nilable(T.any(ActiveStorage::Blob, ActiveStorage::Attachment)),
      direct_upload: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def clearable_file_input(value: nil, direct_upload: true, **attributes)
    Components::ClearableFileInput(
      form: @form,
      field: @field,
      value:,
      direct_upload:,
      **attributes,
    )
  end

  sig { params(attributes: T.untyped).void }
  def textarea(**attributes)
    Components::Textarea(form: @form, field: @field, **attributes)
  end

  sig do
    params(
      options: T.untyped,
      block: T.nilable(T.proc.params(editor: Components::LexxyEditor).void),
    ).void
  end
  def lexxy_editor(**options, &block)
    Components::LexxyEditor(form: @form, field: @field, **options, &block)
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
    if (object = @form&.object) &&
        object.is_a?(ActiveModel::Validations) &&
        (field = @field)
      object.errors.messages_for(field)
    end
  end

  sig { returns(T::Boolean) }
  def invalid?
    @force_invalid || error_messages.present?
  end

  # sig { returns(T.nilable(Symbol)) }
  # def type
  #   if (object_class = @form&.object&.class) &&
  #       object_class.is_a?(ActiveModel::AttributeRegistration::ClassMethods) &&
  #       (field = @field)
  #     case object_class.type_for_attribute(field)
  #     when :string
  #       :text
  #     when :text
  #       :textarea
  #     when :integer, :float, :decimal
  #       :number
  #     when :boolean
  #       :checkbox
  #     end
  #   end
  # end
end
