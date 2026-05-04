# typed: true
# frozen_string_literal: true

class Components::Dialog < Components::Base
  # == Initialization ==

  register_element :el_dialog

  sig do
    params(
      id: String,
      attributes: T.untyped,
    ).void
  end
  def initialize(id: "dialog_#{SecureRandom.uuid}", **attributes)
    @id = id
    @trigger_button_block = T.let(nil, T.nilable(T.proc.void))
    @content_block = T.let(nil, T.nilable(T.proc.void))
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.proc.bind(T.self_type).void).void }
  def view_template(&content)
    vanish(&content)
    trigger_button_block = @trigger_button_block or raise "Missing trigger"
    content_block = @content_block or raise "Missing content"

    el_dialog(**@attributes) do
      trigger_button_block.call
      content_block.call
    end
  end

  # == Interface ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.proc.params(button: Components::Button).void,
    ).void
  end
  def with_trigger_button(variant: :default, size: :default, **attributes, &content)
    @trigger_button_block = ->() {
      render Components::Button.new(
        variant:, size:,
        **mix({ command: "show-modal", commandfor: @id }, attributes),
        &content
      )
    }
  end

  sig do
    params(
      show_close_button: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(content: Components::DialogContent).void,
    ).void
  end
  def with_content(show_close_button: true, **attributes, &content)
    @content_block = ->() {
      render Components::DialogContent.new(
        dialog_id: @id,
        show_close_button:,
        **attributes,
        &content
      )
    }
  end
end
