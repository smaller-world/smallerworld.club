# typed: strict
# frozen_string_literal: true

class Components::AppHeader < Components::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::CurrentPage

  # == Component ==

  sig { override.void }
  def view_template
    root_element(:header, id: :app_header, class: "app-header") do
      Components::DropdownMenu() do |menu|
        menu.with_trigger_button(variant: :ghost, class: "gap-x-1.5") do
          site_name = SmallerWorld.application.site_name
          image_tag(
            "logo.png",
            alt: [ site_name, "logo" ].join(" "),
            class: "size-6",
            data: {
              icon: :inline_start,
            },
          )
          span(class: "font-heading font-semibold text-lg") do
            site_name
          end
        end
        menu.with_content(anchor: :bottom) do |menu_content|
          menu_content(menu_content)
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(content: Components::DropdownMenu::Content).void }
  def menu_content(content)
    if Current.user
      form_with(url: session_path, method: :delete, data: {
        controller: "haptic-bridge",
        action: "turbo:submit-end->haptic-bridge#vibrate",
      }) do
        content.button_item(type: :submit, variant: :destructive, data: {
          action: "dropdown-menu#preventAutoClose",
        }) do
          Icon("huge/logout-01")
          span { "sign out" }
        end
      end
      content.separator
    else
      unless current_page?(controller: "/sessions", action: "new")
        content.link_item_to(new_session_path) do
          Icon("huge/door-01")
          span { "sign in" }
        end
      end
      unless current_page?(controller: "/pages", action: "landing")
        content.link_item_to(root_path) do
          image_tag("logo.png", class: "size-4")
          span { "about smaller world" }
        end
      end
    end

    if (current_device = Current.device) && current_device.push_token?
      form_with(url: test_device_push_token_path, data: {
        controller: "haptic-bridge",
        action: "turbo:submit-end->haptic-bridge#vibrate",
      }) do
        content.button_item(type: :submit) do
          Icon("huge/notification-01")
          span { "send test notification" }
        end
      end
    elsif !hotwire_native_app? && (current_user = Current.user)
      content.link_item_to(home_path) do
        Icon("huge/home-01")
        span { "home" }
      end
      if (world = current_user.owned_worlds.chronological.first)
        content.link_item_to(world_path(world)) do
          Icon("huge/earth")
          span { world.name }
        end
      end
      if current_user.admin?
        content.link_item_to(admin_dashboard_path) do
          Icon("huge/dashboard-square-02")
          span { "admin" }
        end
      end
    end

    unless current_page?(controller: "/contact_requests", action: "new")
      content.separator
      content.link_item_to(new_contact_request_path, data: { turbo_stream: true }) do
        Icon("huge/mail-01")
        span { "contact us" }
      end
    end
  end
end
