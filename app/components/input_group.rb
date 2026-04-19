# typed: true
# frozen_string_literal: true

class Components::InputGroup < Components::Base
  # == Configuration ==

  sig do
    params(
      form: T.nilable(ComponentFormBuilder),
      field: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, **attributes)
    super(**attributes)
    @form = form
    @field = field
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      role: "group",
      class: "group/input-group",
      data: { slot: "input-group" },
      &content
    )
  end

  # == Interface ==

  sig { params(attributes: T.untyped).void }
  def input(**attributes)
    Components::Input(form: @form, field: @field, **attributes)
  end

  sig { params(attributes: T.untyped).void }
  def text_input(**attributes)
    input(type: :text, **attributes)
  end

  sig { params(direct_upload: T::Boolean, attributes: T.untyped).void }
  def file_input(direct_upload: true, **attributes)
    Components::FileInput(
      form: @form,
      field: @field,
      direct_upload:,
      **attributes,
    )
  end

  sig do
    params(
      attributes: T.untyped,
      content: T.proc.params(component: Components::Textarea).void,
    ).void
  end
  def textarea(**attributes, &content)
    Components::Textarea(form: @form, field: @field, **attributes, &content)
  end

  sig do
    params(
      align: String,
      attributes: T.untyped,
      content: T.proc.params(component: Components::InputGroupAddon).void,
    ).void
  end
  def addon(align:, **attributes, &content)
    Components::InputGroupAddon(align:, **attributes, &content)
  end
end
