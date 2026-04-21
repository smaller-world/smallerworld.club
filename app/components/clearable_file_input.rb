# typed: true
# frozen_string_literal: true

class Components::ClearableFileInput < Components::Base
  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      value: T.nilable(T.any(ActiveStorage::Blob, ActiveStorage::Attachment)),
      field: T.nilable(Symbol),
      direct_upload: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, value: nil, field: nil, direct_upload: true, **attributes)
    @form = form
    @field = field
    @direct_upload = direct_upload
    @input_options = T.let(
      delete_from(attributes, :required),
      T.nilable(T::Hash[Symbol, T.untyped]),
    )
    @blob = T.let(
      case value
      when ActiveStorage::Blob
        value
      when ActiveStorage::Attachment
        value.blob
      when nil
        attached_blob
      end,
      T.nilable(ActiveStorage::Blob),
    )
    super(**attributes)
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
        render_empty_inputs_in(group)
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
        render_empty_inputs_in(group)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(ActiveStorage::Blob)) }
  def attached_blob
    if @form && @field
      case value = @form.object.try(@field)
      when ActiveStorage::Attached::One, ActiveStorage::Attachment
        value.blob
      when ActiveStorage::Blob
        value
      end
    end
  end

  sig { params(group: Components::InputGroup).void }
  def render_empty_inputs_in(group)
    if @form && @field
      html = @form.hidden_field(@field, value: nil)
      raw(html) # rubocop:disable Rails/OutputSafety
    end
    group.file_input(direct_upload: @direct_upload, **@input_options)
    group.addon(
      align: :inline_end,
      data: { clearable_file_input_target: "spinner" },
      class: "hidden",
      &:spinner
    )
  end
end
