# typed: strict
# frozen_string_literal: true

class Views::WorldKeys::Show < Views::Base
  include Phlex::Rails::Helpers::FormWith

  # == Initialization ==

  sig { params(world_key: WorldKey).void }
  def initialize(world_key:)
    super()
    @world_key = world_key
    @world = T.let(world_key.world!, World)
    @owner = T.let(@world.owner!, User)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "world settings") do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        button_back_to("world", @world, variant: :secondary)
      end

      app_layout.page_container(class: "max-w-md") do
        Components::Card(
          size: :sm,
          class: "hidden with-notification-token-bridge:revert-display-layer",
        ) do |card|
          card.header do
            card.title(class: "text-center") { "notification settings" }
          end
          card.content do
            form_with(
              url: test_device_push_token_path,
              class: "flex flex-col",
            ) do |form|
              form.hidden_field(:world_id, value: @world.id)
              Components::Button(type: :submit, variant: :secondary) do |button|
                button.inline_start_icon("huge/notification-01")
                span { "send test notification" }
              end
            end
          end
        end

        Components::Card(size: :sm) do |card|
          card.header do
            card.title(class: "text-center") { "break-up zone" }
          end
          card.footer(class: "flex flex-col items-stretch") do
            Components::Popover() do |popover|
              popover.with_trigger_button(variant: :outline) do |button|
                button.inline_start_icon("huge/logout-02")
                span { "leave #{@world.name}" }
              end
              popover.with_content(class: "max-w-60") do |popover_content|
                popover_content.header(class: "text-center") do |popover_header|
                  popover_header.title { "are you sure?" }
                  popover_header.description do
                    "this action is permanent and cannot be undone"
                  end
                end
                Components::Form(@world_key, method: :delete) do |form|
                  form.submit(variant: :destructive, class: "w-full") do |button|
                    button.inline_start_icon("huge/heartbreak")
                    span { "really leave" }
                  end
                end
              end
            end
          end
        end

        div(class: "flex flex-col items-center") do
          button_link_to(
            "report #{@owner.name} and leave world",
            new_user_report_path(@owner, world_id: @world.id),
            class: "text-destructive",
          )
        end
      end
    end
  end
end
