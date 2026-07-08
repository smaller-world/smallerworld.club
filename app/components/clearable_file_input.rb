# typed: strict
# frozen_string_literal: true

class Components::ClearableFileInput < Components::Input
  # sig do
  #   params(
  #     invalid: T.nilable(T::Boolean),
  #     value: T.nilable(ActiveStorage::Blob),
  #     direct_upload: T::Boolean,
  #     attributes: T.untyped,
  #   ).void
  # end
  # def initialize(
  #   invalid: nil,
  #   value: nil,
  #   direct_upload: true,
  #   attributes: T.untyped
  # )
  #   super(invalid:, **attributes)
  #   @direct_upload = direct_upload
  #   # @value = T.let(
  #   #   case value
  #   #   when ActiveStorage::Blob
  #   #     value
  #   #   when ActiveStorage::Attachment
  #   #     value.blob
  #   #   when nil
  #   #     if form && field
  #   #       case value = form.object.try(field)
  #   #       when ActiveStorage::Attached::One, ActiveStorage::Attachment
  #   #         value.blob
  #   #       when ActiveStorage::Blob
  #   #         value
  #   #       end
  #   #     end
  #   #   end,
  #   #   T.nilable(ActiveStorage::Blob),
  #   # )
  # end

  # # == Component ==

  # sig { override(allow_incompatible: true).void }
  # def view_template
  #   Components::InputGroup(
  #     form: @form,
  #     field: @field,
  #     **mix(
  #       {
  #         data: {
  #           controller: "clearable-file-input",
  #         },
  #       },
  #       @attributes,
  #     ),
  #   ) do |input_group|
  #     template(data: { clearable_file_input_target: "inputTemplate" }) do
  #       empty_inputs(input_group:)
  #     end
  #     if @value
  #       if @form && @field
  #         html = @form.hidden_field(@field, id: nil, value: @value.signed_id)
  #         raw(html)
  #       end
  #       input_group.input(value: @value.filename, name: nil, readonly: true)
  #       input_group.addon(align: :inline_end) do |addon|
  #         addon.button(
  #           type: :button,
  #           variant: :destructive,
  #           class: "rounded-md",
  #           data: {
  #             action: "clearable-file-input#clearAttachedFile",
  #           },
  #         ) do |button|
  #           button.inline_start_icon("huge/minus-sign-circle")
  #           span { "remove" }
  #         end
  #       end
  #     else
  #       empty_inputs(input_group:)
  #     end
  #   end
  # end

  # private

  # # == Helpers ==

  # sig { params(input_group: Components::InputGroup).void }
  # def empty_inputs(input_group:)
  #   if @form && @field
  #     html = @form.hidden_field(@field, value: nil)
  #     raw(html)
  #   end
  #   input_group.file_input(direct_upload: @direct_upload, required: @required)
  #   input_group.addon(
  #     align: :inline_end,
  #     data: { clearable_file_input_target: "spinner" },
  #     class: "hidden",
  #     &:spinner
  #   )
  # end
end
