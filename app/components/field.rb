# typed: strict
# frozen_string_literal: true

class Components::Field < Components::Base
  # == Configuration ==

  ORIENTATIONS = [ :vertical, :horizontal, :responsive ]

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      id: T.nilable(String),
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    form: nil,
    field: nil,
    id: nil,
    orientation: :vertical,
    invalid: false,
    **attributes
  )
    unless orientation.in?(ORIENTATIONS)
      raise InvalidParameter.new(parameter: :orientation, value: orientation)
    end

    super(**attributes)
    @form = form
    @field = field
    @id = id
    @orientation = orientation
    @force_invalid = invalid
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    captured_content = capture(&content)

    root_element(
      :div,
      id: @id,
      role: "group",
      class: "field group/field",
      data: {
        slot: "field",
        orientation: @orientation,
        invalid: (true if invalid?),
      },
    ) do
      raw(captured_content) # rubocop:disable Rails/OutputSafety
    end
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
    render Components::FieldLabel.new(
      form: @form,
      field: @field,
      **attributes,
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
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
    ) do
      if content
        yield
      elsif @form && @field
        if (object_class = @form.object&.class) &&
            object_class.is_a?(ActiveModel::Translation)
          object_class.human_attribute_name(@field)
        else
          @field.to_s.humanize
        end
      end
    end
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

  sig do
    params(
      errors: T.nilable(T::Array[String]),
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def error(errors: error_messages, **attributes, &content)
    div(**mix(
      {
        class: "field-error",
        role: "alert",
        data: {
          slot: "field-error",
        },
      },
      attributes,
    )) do
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

  sig { returns(String) }
  def id
    @id ||= if @form && @field
      @form.field_id(@field)
    elsif @field
      @field.to_s
    else
      SecureRandom.uuid
    end
  end

  sig do
    params(
      attributes: T.untyped,
      block: T.nilable(T.proc.params(group: Components::InputGroup).void),
    ).void
  end
  def input_group(**attributes, &block)
    render Components::InputGroup.new(form: @form, field: @field, **attributes, &block)
  end

  sig { params(attributes: T.untyped).void }
  def input(**attributes)
    render Components::Input.new(form: @form, field: @field, **attributes)
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
    render Components::FileInput.new(
      form: @form,
      field: @field,
      value:,
      direct_upload:,
      **attributes,
    )
  end

  sig { params(attributes: T.untyped).void }
  def emoji_input(**attributes)
    render Components::EmojiInput.new(form: @form, field: @field, **attributes)
  end

  sig do
    params(
      value: T.nilable(T.any(ActiveStorage::Blob, ActiveStorage::Attachment)),
      direct_upload: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def clearable_file_input(value: nil, direct_upload: true, **attributes)
    render Components::ClearableFileInput.new(
      form: @form,
      field: @field,
      value:,
      direct_upload:,
      **attributes,
    )
  end

  sig { params(attributes: T.untyped).void }
  def textarea(**attributes)
    render Components::Textarea.new(form: @form, field: @field, **attributes)
  end

  sig do
    params(
      attributes: T.untyped,
      content: T.nilable(T.proc.params(editor: Components::LexxyEditor).void),
    ).void
  end
  def lexxy_editor(**attributes, &content)
    render Components::LexxyEditor.new(form: @form, field: @field, **attributes, &content)
  end

  sig do
    params(
      attributes: T.untyped,
      content: T.proc.params(comobox: Components::Combobox).void,
    ).void
  end
  def combobox(**attributes, &content)
    render Components::Combobox.new(form: @form, field: @field, **attributes, &content)
  end

  sig { params(attributes: T.untyped).void }
  def phone_number_input(**attributes)
    render Components::PhoneNumberInput.new(form: @form, field: @field, **attributes)
  end

  sig do
    params(
      value: T.nilable(T.any(ActiveStorage::Blob, ActiveStorage::Attachment)),
      attributes: T.untyped,
    ).void
  end
  def uppy_dnd(value: nil, **attributes)
    render Components::UppyDnd.new(form: @form, field: @field, value:, **attributes)
  end

  sig do
    params(
      value: T.nilable(T::Array[ActiveStorage::Blob]),
      attributes: T.untyped,
    ).void
  end
  def uppy_group(value: nil, **attributes)
    render Components::UppyGroup.new(form: @form, field: @field, value:, **attributes)
  end

  # sig { params(attributes: T.untyped).void }
  # def otp_input(**attributes)
  #   Components::OtpInput(form: @form, field: @field, **attributes)
  # end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def error_tooltip_attributes
    if (message = error_messages&.first)
      {
        data: {
          controller: "tippy",
          tippy_content_value: message,
          tippy_placement_value: "bottom",
          tippy_show_on_create_value: true,
        },
      }
    else
      {}
    end
  end

  private

  # == Helpers ==

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
