# typed: strict
# frozen_string_literal: true

class Components::Dialog < Components::Base
  register_element :el_dialog

  # == Initialization ==

  sig do
    params(
      dialog_id: String,
      open: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(dialog_id: generate_dialog_id, open: false, **attributes)
    super(**attributes)
    @dialog_id = dialog_id
    @open = open
    @trigger_block = T.let(nil, T.nilable(T.proc.void))
    @content_block = T.let(nil, T.nilable(T.proc.void))
  end

  # == Component ==

  sig { override.params(content: T.proc.bind(T.self_type).void).void }
  def view_template(&content)
    vanish(&content)
    content_block = @content_block or raise "Missing content"

    el_dialog(open: @open, **mix(
      {
        class: "contents",
        data: {
          controller: "dialog",
        },
      },
      @attributes,
    )) do
      @trigger_block&.call
      content_block.call
    end
  end

  # == Interface ==

  sig { returns(String) }
  def generate_dialog_id
    "dialog_#{SecureRandom.uuid}"
  end

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(button: Components::Button).void,
    ).void
  end
  def with_trigger_button(
    variant: :default,
    size: :default,
    invalid: false,
    **attributes,
    &content
  )
    @trigger_block = ->() {
      render Components::Button.new(
        type: :button,
        variant:,
        size:,
        invalid:,
        **mix(
          {
            command: "show-modal",
            commandfor: @dialog_id,
          },
          attributes,
        ),
        &content
      )
    }
  end

  sig { params(block: T.proc.void).void }
  def with_trigger(&block)
    @trigger_block = block
  end

  sig do
    params(
      show_close_button: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(content: Components::Dialog::Content).void,
    ).void
  end
  def with_content(show_close_button: true, **attributes, &content)
    @content_block = ->() {
      render Components::Dialog::Content.new(
        dialog_id: @dialog_id,
        show_close_button:,
        **attributes,
        &content
      )
    }
  end
end
