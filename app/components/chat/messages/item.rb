# typed: true
# frozen_string_literal: true

class Components::Chat::Messages::Item < Components::Base
  # == Configuration ==

  sig { params(message: WhatsappMessage).void }
  def initialize(message:)
    super()
    @message = message
  end

  # == Component ==

  sig { override.void }
  def view_template
    li do
      div(
        class: "chat_message group/message",
        data: {
          sender: ("you" if @message.from_application_user?),
        },
      ) do
        unless @message.from_application_user?
          if (src = @message.sender!.profile_picture_url)
            image_tag(src, class: "chat_avatar")
          else
            div(class: "chat_avatar chat_avatar-fallback") do
              Icon("hero/user", variant: :solid, class: "size-4")
            end
          end
        end
        div(class: "chat_message_body") do
          div(class: "chat_message_sender px-1") do
            sender_label(@message)
          end
          if (quoted_message = @message.quoted_message)
            div(class: "chat_message_quote") do
              div(class: "chat_message_sender") do
                sender_label(quoted_message)
              end
              p { render_body(quoted_message) }
            end
          end
          div(class: "chat_message_content") do
            p { render_body(@message) }
            local_time(
              @message.timestamp,
              format: "%l:%M %p",
              class: "float-right invisible pl-1",
            )
            local_time(
              @message.timestamp,
              format: "%l:%M %p",
              class: "absolute bottom-1 right-1.5 cursor-pointer",
              data: {
                controller: "clipboard tooltip",
                action: class_names(
                  "click->clipboard#copy",
                  "clipboard:copied->tooltip#flash",
                ),
                clipboard_copy_value: @message.whatsapp_id,
                tooltip_trigger_value: "manual",
                tooltip_content_value: "copied WhatsApp message ID!",
                tooltip_flash_duration_value: 1400,
              },
            )
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(message: WhatsappMessage).void }
  def render_body(message)
    mentioned_users = message.mentioned_users.filter do |user|
      user.phone_mention_token.present?
    end
    if mentioned_users.empty?
      render_body_text(message.body)
      return
    end

    mentions_by_token = T.let({}, T::Hash[String, WhatsappUser])
    mentioned_users.each do |user|
      user.mention_tokens.each do |token|
        mentions_by_token[token] = user
      end
    end
    pattern = Regexp.union(mentions_by_token.keys)
    parts = message.body.split(/(#{pattern})/)

    parts.each do |part|
      if (user = mentions_by_token[part])
        href = if (phone = user.phone)
          "https://wa.me/#{phone.sanitized}"
        end
        a(class: "link font-bold", href:) do
          span(class: "text-muted-foreground") { "@" }
          if user.application_user?
            plain(Rails.configuration.x.site_name)
          else
            plain(
              user.display_name ||
                user.phone&.international(true) ||
                user.lid,
            )
          end
        end
      else
        render_body_text(part)
      end
    end
  end

  sig { params(text: String).void }
  def render_body_text(text)
    raw(auto_link(text, html: { class: "link" })) # rubocop:disable Rails/OutputSafety
  end

  sig { params(message: WhatsappMessage).returns(String) }
  def sender_label(message)
    sender = message.sender!
    if sender.application_user?
      Rails.configuration.x.site_name
    else
      sender.display_name ||
        sender.phone&.international(true) ||
        sender.lid
    end
  end
end
