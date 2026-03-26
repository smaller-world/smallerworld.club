# typed: true
# frozen_string_literal: true

module MessagingHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  MESSAGING_PLATFORMS = %w[sms telegram whatsapp].freeze

  sig do
    params(
      phone_number: String,
      body: String,
      platform: String,
    ).returns(String)
  end
  def message_uri(phone_number, body, platform)
    if platform == "whatsapp"
      body = body.gsub("\n> \n", "\n") + "\u2800"
    end
    encoded_body = ERB::Util.url_encode(body)
    case platform
    when "sms"
      "sms:#{phone_number}?body=#{encoded_body}"
    when "telegram"
      "https://t.me/#{phone_number}?text=#{encoded_body}"
    when "whatsapp"
      "https://wa.me/#{phone_number}?text=#{encoded_body}"
    else
      raise ArgumentError, "Unknown messaging platform: #{platform}"
    end
  end

  sig { params(platform: String).returns(String) }
  def messaging_platform_label(platform)
    platform
  end

  sig { params(platform: String, options: T.untyped).returns(String) }
  def messaging_platform_icon(platform, **options)
    case platform
    when "sms"
      icon("chat-bubble-bottom-center-text", variant: :micro, **options)
    when "telegram"
      icon("telegram-logo", library: :phosphor, fill: "currentColor", **options)
    when "whatsapp"
      icon("whatsapp-logo", library: :phosphor, fill: "currentColor", **options)
    else
      raise ArgumentError, "Unknown messaging platform: #{platform}"
    end
  end
end
