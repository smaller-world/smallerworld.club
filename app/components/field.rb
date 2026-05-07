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
    root_element(
      :div,
      role: "group",
      class: "field group/field",
      data: {
        slot: "field",
        orientation: @orientation,
        invalid: (true if invalid?),
      },
      &content
    )
  end

  # == Interface ==

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def content(**attributes, &content)
    slot(
      "field-content",
      **mix({ class: "group/field-content" }, attributes),
      &content
    )
  end

  sig { params(options: T.untyped, content: T.nilable(T.proc.void)).void }
  def label(**options, &content)
    options = mix(
      {
        class: "field-label group/field-label peer/field-label",
        data: {
          slot: "field-label",
        },
      },
      **options,
    )
    if @form && @field
      html = @form.label(@field, **options) do
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
      super(**options, &content)
    end
  end

  sig { params(options: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**options, &content)
    slot("field-title", **options, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
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

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def separator(**attributes, &content)
    slot(
      "field-separator",
      **mix({ data: { content: block_given? } }, attributes),
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

  sig do
    params(
      errors: T.nilable(T::Array[String]),
      options: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def error(errors: error_messages, **options, &content)
    return if content.nil? && errors.blank?

    slot("field-error", role: "alert", **options) do
      if block_given?
        yield
      elsif (errors = errors.presence)
        if errors.length == 1
          errors.first
        else
          ul do
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

  sig { params(options: T.untyped).void }
  def input(**options)
    Components::Input(form: @form, field: @field, **options)
  end

  sig { params(options: T.untyped).void }
  def text_input(**options)
    input(type: :text, **options)
  end

  sig do
    params(
      value: T.nilable(T.any(ActiveStorage::Blob, ActiveStorage::Attachment)),
      direct_upload: T::Boolean,
      options: T.untyped,
    ).void
  end
  def file_input(
    value: nil,
    direct_upload: true,
    **options
  )
    Components::FileInput(
      form: @form,
      field: @field,
      value:,
      direct_upload:,
      **options,
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

  sig { params(options: T.untyped).void }
  def textarea(**options)
    Components::Textarea(form: @form, field: @field, **options)
  end

  sig do
    params(
      options: T.untyped,
      content: T.nilable(T.proc.params(editor: Components::LexxyEditor).void),
    ).void
  end
  def lexxy_editor(**options, &content)
    Components::LexxyEditor(form: @form, field: @field, **options, &content)
  end

  sig do
    params(
      options: T.untyped,
      content: T.proc.params(comobox: Components::Combobox).void,
    ).void
  end
  def combobox(**options, &content)
    Components::Combobox(form: @form, field: @field, **options, &content)
  end

  sig { params(options: T.untyped).void }
  def phone_number_input(**options)
    Components::PhoneNumberInput(form: @form, field: @field, **options)
  end

  # sig { params(attributes: T.untyped).void }
  # def otp_input(**attributes)
  #   Components::OtpInput(form: @form, field: @field, **attributes)
  # end

  private

  # == Helpers ==

  sig do
    params(
      name: String,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def slot(name, **attributes, &content)
    div(
      **mix(
        {
          class: name,
          data: { name: },
        },
        attributes,
      ),
      &content
    )
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
