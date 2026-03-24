# typed: true
# frozen_string_literal: true

class Views::Admin::WebhookMessages::Index < Views::Base
  # == Configuration ==

  sig { params(messages: T::Enumerable[WebhookMessage], pagy: Pagy::Offset).void }
  def initialize(messages:, pagy:)
    super()
    @messages = messages
    @pagy = pagy
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout() do |layout|
      layout.page_container(class: "flex flex-col gap-y-4") do
        div do
          h1(class: "text-2xl font-bold") { "webhook logs" }
          link_to(
            "back to admin dashboard",
            [ :admin, :dashboard ],
            class: "link",
          )
        end
        if @messages.any?
          ul(class: "space-y-4") do
            @messages.each do |message|
              li do
                Components::Card() do |card|
                  card.header do
                    card.title(
                      class: "font-semibold flex gap-x-2 justify-between",
                    ) do
                      Components::Badge() { message.event }
                      local_time(
                        message.timestamp,
                        format: :short,
                        class: "text-xs text-muted-foreground lowercase",
                      )
                    end
                    if (group = message.associated_whatsapp_group)
                      card.description do
                        link_to(
                          [ :message_history, group ],
                          class: "link inline-flex items-center gap-x-1",
                        ) do
                          Icon("huge/arrow-right-02", class: "size-4.5")
                          span { group.subject || group.jid }
                        end
                      end
                    end
                  end
                  card.content(class: "overflow-x-auto") do
                    pre(class: "text-sm") do
                      JSON.pretty_generate(message.data)
                    end
                  end
                end
              end
            end
          end
        else
          p(class: "text-muted-foreground") do
            "no webhook messages found..."
          end
        end
        if @pagy.count > 0 # rubocop:disable Style/CollectionQuerying
          div(class: "flex flex-col items-center gap-y-2 mt-2") do
            div(class: "text-sm text-muted-foreground") do
              raw(safe(@pagy.info_tag)) # rubocop:disable Rails/OutputSafety
            end
            raw(safe(@pagy.series_nav)) # rubocop:disable Rails/OutputSafety
          end
        end
      end
    end
  end
end
