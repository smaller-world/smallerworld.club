# typed: true
# frozen_string_literal: true

class Components::Chat < Components::Base
  sig do
    params(
      group: WhatsappGroup,
      messages: T::Array[WhatsappMessage],
      pagy: T.nilable(Pagy),
      attributes: T.untyped,
    ).void
  end
  def initialize(group:, messages: [], pagy: nil, **attributes)
    super(**attributes)
    @group = group
    @messages = messages
    @pagy = pagy
  end

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    vanish(&content)

    Components::Card(
      size: :sm,
      **mix({ class: "chat_card" }, @attributes),
    ) do |card|
      card.header(class: "flex items-center gap-x-3 border-b") do
        if view_context && (url = @group.profile_picture_url)
          image_tag(url, class: "size-12 rounded-full")
        end
        div(class: "flex flex-col gap-y-1") do
          card.title(class: "text-2xl font-bold") do
            @group.subject || @group.jid
          end
          if (description = @group.description)
            card.description { description }
          end
        end
      end
      card.content(
        class: "chat_content",
        data: {
          controller: "maintain-scroll",
        },
      ) do
        div(class: "chat_empty_indicator") do
          p(class: "text-muted-foreground text-sm") do
            "no messages found 😪"
          end
        end
        if @pagy.nil? || @pagy.next
          render PaginationButton.new(group: @group, pagy: @pagy)
        end
        ul(id: "messages", class: "chat_messages") do
          render Messages.new(messages: @messages)
        end
      end
    end
  end
end
