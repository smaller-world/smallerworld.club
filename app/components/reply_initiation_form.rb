# typed: strict
# frozen_string_literal: true

class Components::ReplyInitiationForm < Components::Base
  # == Initialization ==

  sig do
    params(
      reply_initiation: ReplyInitiation,
      replied_post_ids: T::Set[String],
      attributes: T.untyped,
    ).void
  end
  def initialize(reply_initiation:, replied_post_ids:, **attributes)
    super(**attributes)
    @reply_initiation = reply_initiation
    @replied_post_ids = replied_post_ids
    @post = T.let(@reply_initiation.post!, Post)
  end

  sig { override.void }
  def view_template
    form_with(
      id: dom_id(@post, :reply_initiation),
      model: [ @post, @reply_initiation ],
      url: [ @post, :reply_initiations ],
      method: :post,
      data: {
        controller: "reply-initiation-form haptic-bridge",
        action: "turbo:submit-end->haptic-bridge#vibrate",
      },
      **@attributes,
    ) do |form|
      form.hidden_field(:platform, required: true, data: {
        reply_initiation_form_target: "platformInput",
      })

      Components::DropdownMenu() do |menu|
        menu.with_trigger_button(
          variant: button_variant,
          **compact_mix(
            {
              class: "loading-while-submitting",
              data: {
                reply_initiation_form_target: "disableWhileSubmitting",
              },
              aria: {
                invalid: ("true" if error_messages.any?),
              },
            },
            error_tooltip_attributes,
          ),
        ) do |button|
          button.inline_start_icon("huge/message-01")
          span { "reply via" }
        end

        menu.with_content(anchor: [ :bottom ]) do |content|
          ReplyInitiation.platform.values.each do |platform|
            content.button_item(data: {
              action: "reply-initiation-form#setPlatformValue",
              platform:,
            }) do
              platform_icon(platform)
              span { platform.to_s.humanize(capitalize: false) }
            end
          end
        end
      end
    end

    if @reply_initiation.previously_new_record?
      a(
        id: dom_id(@reply_initiation, :link),
        href: @reply_initiation.reply_url(native: hotwire_native_app?),
        hidden: true,
        data: {
          controller: "autoclick",
          autoclick_once_value: true,
        },
      )
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

  sig { returns(Symbol) }
  def button_variant
    if @replied_post_ids.include?(@post.id)
      :ghost
    else
      :default
    end
  end

  sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def error_tooltip_attributes
    if (message = error_messages.first)
      {
        data: {
          controller: "tippy",
          tippy_content_value: message,
          tippy_placement_value: "bottom",
          tippy_show_on_create_value: true,
        },
      }
    end
  end

  sig { returns(T::Array[String]) }
  def error_messages
    @reply_initiation.errors.messages_for(:platform)
  end
end
