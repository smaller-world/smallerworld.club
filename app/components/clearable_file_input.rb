# typed: strict
# frozen_string_literal: true

class Components::ClearableFileInput < Components::Input
  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      value: T.nilable(T.any(ActiveStorage::Blob, ActiveStorage::Attachment)),
      direct_upload: T::Boolean,
      required: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    form: nil,
    field: nil,
    value: nil,
    direct_upload: true,
    required: false,
    attributes: T.untyped
  )
    @direct_upload = direct_upload
    @required = required
    @blob = T.let(
      case value
      when ActiveStorage::Blob
        value
      when ActiveStorage::Attachment
        value.blob
      when nil
        if form && field
          case value = form.object.try(field)
          when ActiveStorage::Attached::One, ActiveStorage::Attachment
            value.blob
          when ActiveStorage::Blob
            value
          end
        end
      end,
      T.nilable(ActiveStorage::Blob),
    )
    super(form:, field:, **attributes)
  end

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    Components::InputGroup(
      form: @form,
      field: @field,
      **mix(
        { data: { controller: "clearable-file-input" } },
        @attributes,
      ),
    ) do |group|
      template(data: { clearable_file_input_target: "inputTemplate" }) do
        empty_inputs(group:)
      end
      if @blob
        if @form && @field
          html = @form.hidden_field(@field, id: nil, value: @blob.signed_id)
          raw(html) # rubocop:disable Rails/OutputSafety
        end
        group.input(value: @blob.filename, name: nil, readonly: true)
        group.addon(align: :inline_end) do |addon|
          addon.button(
            type: :button,
            variant: :destructive,
            class: "rounded-md",
            data: {
              action: "clearable-file-input#clearAttachedFile",
            },
          ) do |button|
            button.inline_start_icon("huge/minus-sign-circle")
            span { "remove" }
          end
        end
      else
        empty_inputs(group:)
      end
    end
  end

  private

  # == Helpers ==

  sig { params(group: Components::InputGroup).void }
  def empty_inputs(group:)
    if @form && @field
      html = @form.hidden_field(@field, value: nil)
      raw(html) # rubocop:disable Rails/OutputSafety
    end
    group.file_input(direct_upload: @direct_upload, required: @required)
    group.addon(
      align: :inline_end,
      data: { clearable_file_input_target: "spinner" },
      class: "hidden",
      &:spinner
    )
  end
end
