# typed: strict
# frozen_string_literal: true

class Components::ConfirmDeleteButton < Components::Base
  include Phlex::Rails::Helpers::FormWith

  # == Initialization ==

  sig do
    params(
      url: Object,
      description: String,
      confirm_label: String,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    url:,
    description: "this action is permanent and cannot be undone",
    confirm_label: "really delete",
    **attributes
  )
    super(**attributes)
    @url = url
    @description = description
    @confirm_label = confirm_label
  end

  # == Component ==

  sig { override.params(content: T.proc.params(button: Components::Button).void).void }
  def view_template(&content)
    Components::Popover() do |popover|
      popover.with_trigger_button(**@attributes, &content)
      popover.with_content(class: "max-w-60") do |popover_content|
        popover_content.header(class: "text-center") do |popover_header|
          popover_header.title { "are you sure?" }
          popover_header.description { @description }
        end
        form_with(url: @url, method: :delete, data: {
          controller: "haptic-bridge",
          action: "turbo:submit-end->haptic-bridge#vibrate",
        }) do
          Components::Button(
            type: :submit,
            variant: :destructive,
            class: "w-full",
          ) do |button|
            button.inline_start_icon("huge/delete-01")
            span { @confirm_label }
          end
        end
      end
    end
  end
end
