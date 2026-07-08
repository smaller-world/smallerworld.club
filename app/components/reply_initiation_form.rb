# typed: strict
# frozen_string_literal: true

class Components::ReplyInitiationForm < Components::Base
  # == Initialization ==

  sig do
    params(
      reply_initiation: ReplyInitiation,
      replied: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(reply_initiation:, replied:, **attributes)
    super(**attributes)
    @reply_initiation = reply_initiation
    @replied = replied
    @post = T.let(@reply_initiation.post!, Post)
  end

  sig { override.void }
  def view_template
    Components::Form(
      @reply_initiation,
      action: [ @post, :reply_initiations ],
      id: dom_id(@post, :reply_initiation_form),
      data: {
        controller: "messaging-platform-dropdown haptic-bridge",
        action: "turbo:submit-end->haptic-bridge#vibrate",
      },
      **@attributes,
    ) do |form|
      Components::Field(invalid: form.invalid?(:platform)) do
        form.Field(:platform).hidden(required: true, data: {
          messaging_platform_dropdown_target: "input",
        })
        Components::DropdownMenu() do |menu|
          menu.with_trigger_button(
            variant: @replied ? :ghost : :default,
            invalid: form.invalid?(:platform),
            **mix(
              {
                class: "loading-while-submitting",
                data: {
                  controller: "disable-while-submitting",
                },
              },
              form.error_tooltip_attributes_for(:platform),
            ),
          ) do |button|
            button.inline_start_icon("huge/message-01")
            span { "reply via" }
          end

          menu.with_content(anchor: [ :bottom ]) do |menu_content|
            ReplyInitiation.platform.values.each do |platform|
              menu_content.button_item(data: {
                action: "messaging-platform-dropdown#setInputValue",
                platform:,
              }) do
                platform_icon(platform)
                span { platform.to_s.humanize(capitalize: false) }
              end
            end
          end
        end
      end
    end

    if @reply_initiation.previously_new_record?
      Components::AutoclickingReplyLink(reply_initiation: @reply_initiation)
    end
  end

  private

  # == Helpers ==

  sig { params(platform: Enumerize::Value).void }
  def platform_icon(platform)
    icon = case platform
    when "sms"
      "huge/message-01"
    when "whatsapp"
      "huge/whatsapp"
    when "telegram"
      "huge/telegram"
    else
      raise ArgumentError, "Unknown platform: #{platform}"
    end
    Icon(icon)
  end
end
