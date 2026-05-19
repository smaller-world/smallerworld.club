# typed: true
# frozen_string_literal: true

class Components::Dialog::Content < Components::Base
  register_element :el_dialog_backdrop
  register_element :el_dialog_panel

  # == Initialization ==

  sig do
    params(
      dialog_id: String,
      show_close_button: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    dialog_id:,
    show_close_button: true,
    **attributes
  )
    @dialog_id = dialog_id
    @show_close_button = show_close_button
    super(**attributes)
  end

  # == Component ==

  sig { override.params(block: T.proc.bind(T.self_type).void).void }
  def view_template(&block)
    dialog(id: @dialog_id) do
      el_dialog_backdrop(
        class: "dialog-overlay",
        data: {
          slot: "dialog-overlay",
        },
      )
      el_dialog_panel(
        class: "dialog-content",
        data: {
          slot: "dialog-content",
        },
      ) do
        yield
        if @show_close_button
          Components::Button(
            variant: :ghost,
            size: :icon_sm,
            type: "button",
            class: "dialog-close",
            data: {
              slot: "dialog-close",
            },
            command: "close",
            commandfor: @dialog_id,
          ) do
            Icon("huge/cancel-01")
            span(class: "sr-only") { "close" }
          end
        end
      end
    end
  end

  # == Slots ==

  sig do
    params(
      attributes: T.untyped,
      content: T.proc.params(header: Components::Dialog::Header).void,
    ).void
  end
  def header(**attributes, &content)
    render Components::Dialog::Header.new(**attributes, &content)
  end

  sig do
    params(
      show_close_button: T::Boolean,
      attributes: T.untyped,
      content: T.proc.void,
    ).void
  end
  def footer(
    show_close_button: false,
    **attributes,
    &content
  )
    div(
      **mix(
        {
          class: "dialog-footer",
          data: { slot: "dialog-footer" },
        },
        attributes,
      ),
    ) do
      yield
      if show_close_button
        Components::Button(
          variant: :outline,
          type: "button",
          command: "close",
          commandfor: @dialog_id,
        ) do
          "close"
        end
      end
    end
  end
end
