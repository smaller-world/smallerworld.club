# typed: strict
# frozen_string_literal: true

class Components::Dialog::Content < Components::Base
  include DeleteFrom

  # == Configuration ==

  register_element :el_dialog_backdrop
  register_element :el_dialog_panel

  # == Initialization ==

  sig do
    params(
      show_close_button: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    show_close_button: true,
    **attributes
  )
    super(**attributes)
    @show_close_button = show_close_button
  end

  # == Component ==

  sig { override.params(content: T.proc.bind(T.self_type).void).void }
  def view_template(&content)
    attributes = @attributes
    panel_attributes = delete_from(attributes, :class)

    dialog(**mix(
      {
        data: {
          dialog_target: "content",
        },
      },
      @attributes,
    )) do
      el_dialog_backdrop(
        class: "dialog-overlay",
        data: {
          slot: "dialog-overlay",
        },
      )
      el_dialog_panel(
        **mix(
          {
            class: "dialog-content",
            data: {
              slot: "dialog-content",
            },
          },
          panel_attributes,
        ),
      ) do
        yield
        if @show_close_button
          Components::Button(
            type: "button",
            variant: :ghost,
            size: :icon_sm,
            class: "dialog-close",
            data: {
              slot: "dialog-close",
              action: "dialog#close",
            },
          ) do
            Icon("huge/cancel-01")
            span(class: "sr-only") { "close" }
          end
        end
      end
    end
  end

  # == Interface  ==

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
      close_button if show_close_button
    end
  end

  sig do
    params(
      attributes: T.untyped,
      content: T.nilable(T.proc.params(button: Components::Button).void),
    ).void
  end
  def close_button(**attributes, &content)
    Components::Button(
      type: :button,
      variant: :outline,
      data: {
        action: "dialog#close",
      },
      **attributes,
    ) do |button|
      if block_given?
        yield(button)
      else
        "close"
      end
    end
  end
end
