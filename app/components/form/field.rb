# typed: strict
# frozen_string_literal: true

# Extend the Field class to add your own custom helpers.
class Components::Form
  class Field < Superform::Rails::Form::Field
    extend T::Sig

    sig do
      override.params(
        attributes: T.untyped,
        content: T.nilable(
          T.proc.params(field_label: Components::FieldLabel).returns(T.anything),
        ),
      ).returns(Label)
    end
    def label(**attributes, &content)
      Label.new(self, **attributes, &content)
    end

    sig do
      params(
        attributes: T.untyped,
        content: T.nilable(
          T.proc.params(field_error: Components::FieldError).returns(T.anything),
        ),
      ).returns(Error)
    end
    def error(**attributes, &content)
      Error.new(self, **attributes, &content)
    end

    sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
    def error_tooltip_attributes
      if (message = errors.first)
        {
          data: {
            controller: "tooltip connection",
            tooltip_content_value: message,
            tooltip_placement_value: "bottom",
            action: "connection:connect->tooltip#show",
          },
        }
      end
    end

    sig do
      override.params(
        attributes: T.untyped,
        content: T.nilable(T.proc.params(input: Input).void),
      ).returns(Input)
    end
    def input(**attributes, &content)
      Input.new(self, **attributes, &content)
    end

    sig do
      override
        .params(direct_upload: T::Boolean, attributes: T.untyped)
        .returns(FileInput)
    end
    def file(direct_upload: true, **attributes)
      FileInput.new(self, **attributes)
    end

    sig do
      override.params(
        index: T.nilable(Integer),
        toggleable: T::Boolean,
        attributes: T.untyped,
      ).returns(Radio)
    end
    def radio(index: nil, toggleable: false, **attributes)
      Radio.new(self, index:, toggleable:, **attributes)
    end

    sig do
      override.type_parameters(:U)
        .params(
          options: T.any(
            T::Array[[ String, T.type_parameter(:U) ]],
            T::Enumerable[T.type_parameter(:U)],
          ),
          toggleable: T::Boolean,
          attributes: T.untyped,
          content: T.nilable(T.proc.params(
            choice: Choices::Choice[T.type_parameter(:U)],
          ).returns(T.anything)),
        ).returns(Radios[T.type_parameter(:U)])
    end
    def radios(options, toggleable: false, **attributes, &content)
      # options = enum_options if options.empty?
      Radios.new(field, options:, toggleable:, **attributes, &content)
    end

    sig do
      override
        .params(index: T.nilable(Integer), attributes: T.untyped)
        .returns(Checkbox)
    end
    def checkbox(index: nil, **attributes)
      Checkbox.new(self, index:, **attributes)
    end

    sig do
      override.type_parameters(:U)
        .params(
          options: T::Enumerable[T.type_parameter(:U)],
          include_hidden: T::Boolean,
          attributes: T.untyped,
          content: T.nilable(T.proc.params(
            choice: Choices::Choice[T.type_parameter(:U)],
          ).returns(T.anything)),
        ).returns(Checkboxes[T.type_parameter(:U)])
    end
    def checkboxes(options, include_hidden: true, **attributes, &content)
      # options = enum_options if options.empty?
      Checkboxes.new(field, options:, include_hidden:, **attributes, &content)
    end

    sig do
      type_parameters(:U).params(
        options: T.all(T.type_parameter(:U), T::Enumerable[T.anything], Object),
        multiple: T::Boolean,
        attributes: T.untyped,
        content: T.nilable(
          T.proc.params(select: Select[ T.all(
            T.type_parameter(:U),
            T::Enumerable[T.anything],
            Object,
          )]).void,
        ),
      ).returns(Select[T.all(T.type_parameter(:U), T::Enumerable[T.anything], Object)])
    end
    def select(options, multiple: false, **attributes, &content)
      Select.new(
        field,
        options:,
        multiple:,
        **attributes,
        &content
      )
    end

    sig { params(attributes: T.untyped).returns(PhoneNumber) }
    def phone_number(**attributes)
      PhoneNumber.new(self, **attributes)
    end

    sig { params(attributes: T.untyped).returns(Emoji) }
    def emoji(**attributes)
      Emoji.new(self, **attributes)
    end

    sig { params(attributes: T.untyped).returns(Lexxy) }
    def lexxy(**attributes)
      Lexxy.new(self, **attributes)
    end

    sig do
      params(
        required: T::Boolean,
        allowed_file_types: T.nilable(T::Array[String]),
        crop_to_aspect_ratio: T.nilable(Numeric),
        preview_fit: T.nilable(Symbol),
        dropzone_class: T.nilable(String),
        attributes: T.untyped,
      ).returns(Uppy)
    end
    def uppy(
      required: false,
      allowed_file_types: nil,
      crop_to_aspect_ratio: nil,
      preview_fit: nil,
      dropzone_class: nil,
      **attributes
    )
      Uppy.new(
        self,
        required:,
        allowed_file_types:,
        crop_to_aspect_ratio:,
        preview_fit:,
        dropzone_class:,
        **attributes,
      )
    end

    sig do
      params(
        max_number_of_files: T.nilable(Integer),
        required: T::Boolean,
        allowed_file_types: T.nilable(T::Array[String]),
        crop_to_aspect_ratio: T.nilable(Numeric),
        preview_fit: T.nilable(Symbol),
        dropzone_class: T.nilable(String),
        attributes: T.untyped,
      ).returns(UppyGroup)
    end
    def uppy_group(
      max_number_of_files: nil,
      required: false,
      allowed_file_types: nil,
      crop_to_aspect_ratio: nil,
      preview_fit: nil,
      dropzone_class: nil,
      **attributes
    )
      UppyGroup.new(
        self,
        max_number_of_files:,
        required:,
        allowed_file_types:,
        crop_to_aspect_ratio:,
        preview_fit:,
        dropzone_class:,
        **attributes,
      )
    end

    sig { params(post: Post, attributes: T.untyped).returns(PostRecipientsSelect) }
    def post_recipients_select(post:, **attributes)
      PostRecipientsSelect.new(self, post:, **attributes)
    end

    # # Overide base form helpers for small modifications, like injecting
    # # default classes or styles.
    # def input(class: nil, **)
    #   super(class: ["border p-2", grab(class:)], **)
    # end
    #
    # # Create custom field helpers that may be accessed via `fied(:email).my_input`
    # def required_email(**)
    #   input(type: "email", required: true, **)
    # end
    #
    # # Return your own component if you're doing more complicated things.
    # def autocomplete(**attributes)
    #   Components::Autocomplete.new(field, **attributes)
    # end
  end
end
