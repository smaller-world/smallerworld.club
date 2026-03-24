# typed: true
# frozen_string_literal: true

class Views::Admin::Dashboard::Show < Views::Base
  sig { override.void }
  def view_template
    Components::Layout() do |layout|
      layout.page_container(class: "flex flex-col gap-y-4") do
        div do
          h1(class: "text-2xl font-bold") { "admin dashboard" }
          blockquote(class: "italic text-muted-foreground") do
            "“so ya wanna run for happy town mayor, is that right?”"
          end
        end

        div(class: "flex flex-col gap-y-1") do
          h2(class: "text-xl font-semibold") { "quick links" }
          ul(class: "list-disc ml-6 space-y-0.5") do
            li do
              link_to("webhook logs", [ :admin, :webhook_messages ], class: "link")
            end
            li do
              link_to("background jobs", [ :mission_control, :jobs ], class: "link")
            end
          end
        end

        div(class: "flex flex-col gap-y-1") do
          h2(class: "text-xl font-semibold") do
            "recently active whatsapp groups"
          end
          ul(class: "list-disc ml-6 space-y-0.5") do
            WhatsappGroup.by_recent_activity.limit(100).each do |group|
              li do
                link_to(
                  group.subject || group.jid,
                  [ :message_history, group ],
                  class: "link",
                )
                ul(class: "list-disc ml-6 space-y-0.5") do
                  if (last_message = group.messages.chronological.last)
                    li(class: "text-sm text-muted-foreground") do
                      span(class: "font-medium") { "last message" }
                      plain(" at ")
                      local_time(
                        last_message.timestamp,
                        format: :short,
                        class: "lowercase font-medium",
                      )
                    end
                  end
                  if (last_synced_at = group.metadata_imported_at)
                    li(class: "text-sm text-muted-foreground") do
                      span(class: "font-medium") { "group metadata" }
                      plain(" last synced at")
                      whitespace
                      local_time(
                        last_synced_at,
                        format: :short,
                        class: "lowercase font-medium",
                      )
                    end
                  end
                  if (last_memberships_synced_at = group.memberships_imported_at)
                    li(class: "text-sm text-muted-foreground") do
                      span(class: "font-medium") { "group participants" }
                      plain(" last synced at")
                      whitespace
                      local_time(
                        last_memberships_synced_at,
                        format: :short,
                        class: "lowercase font-medium",
                      )
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
