# typed: true
# frozen_string_literal: true

class Components::Dialog < Components::Base
  # == Configuration ==

  register_element :el_dialog
  register_element :el_dialog_backdrop
  register_element :el_dialog_panel

  sig do
    params(
      id: String,
      show_close_button: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(id:, show_close_button: true, **attributes)
    super(**attributes)
    @id = id
    @show_close_button = show_close_button
  end

  # == Component ==

  sig { override.params(block: T.proc.bind(T.self_type).void).void }
  def view_template(&block)
    el_dialog do
      dialog(
        id: @id,
        aria_labelledby: "#{@id}-title",
        data: {
          slot: "dialog-content",
          controller: "dialog",
        },
      ) do
        el_dialog_backdrop(data: { slot: "dialog-overlay" })
        div(data: { slot: "dialog-inner" }) do
          el_dialog_panel(data: { slot: "dialog-panel" }) do
            yield
            close_button if @show_close_button
          end
        end
      end
    end
  end

  # == Slots ==

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def header(**attributes, &block)
    div(**mix({ data: { slot: "dialog-header" } }, attributes), &block)
  end

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def title(**attributes, &block)
    h3(
      **mix(
        { id: "#{@id}-title", data: { slot: "dialog-title" } },
        attributes,
      ),
      &block
    )
  end

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def description(**attributes, &block)
    p(**mix({ data: { slot: "dialog-description" } }, attributes), &block)
  end

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def body(**attributes, &block)
    div(**attributes, &block)
  end

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def footer(**attributes, &block)
    div(**mix({ data: { slot: "dialog-footer" } }, attributes), &block)
  end

  private

  # == Helpers ==

  sig { void }
  def close_button
    div(data: { slot: "dialog-close" }) do
      Components::Button(
        variant: :ghost,
        size: "icon-sm",
        command: "close",
        commandfor: @id,
      ) do
        Icon("huge/cancel-01", class: "size-4")
        span(class: "sr-only") { "Close" }
      end
    end
  end
end
