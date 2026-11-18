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
    [ action_items, user_items, general_items ].compact_blank.each_with_index do |items, index|
      content.separator unless index.zero?
      items.each do |item|
        item.render_in(content)
      end
    end
  end

  sig { returns(T::Array[MenuItem]) }
  def action_items
    items = T.let([], T::Array[MenuItem])
    if Current.user
      items << MenuItem.new do |content|
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
      end
    else
      items << MenuItem.new do |content|
        content.link_item_to(new_session_path) do
          Icon("huge/door-01")
          span { "sign in" }
        end
      end
    end
    if (current_device = Current.device) && current_device.push_token?
      items << MenuItem.new do |content|
        form_with(url: test_device_push_token_path, data: {
          controller: "haptic-bridge",
          action: "turbo:submit-end->haptic-bridge#vibrate",
        }) do
          content.button_item(type: :submit) do
            Icon("huge/notification-01")
            span { "send test notification" }
          end
        end
      end
    end
    items
  end

  sig { returns(T::Array[MenuItem]) }
  def user_items
    items = T.let([], T::Array[MenuItem])
    if (current_user = Current.user)
      unless hotwire_native_app?
        items << MenuItem.new do |content|
          content.link_item_to(home_path) do
            Icon("huge/home-01")
            span { "home" }
          end
        end
      end
      if !hotwire_native_app? && (world = current_user.owned_worlds.chronological.first)
        items << MenuItem.new do |content|
          content.link_item_to(world_path(world)) do
            Icon("huge/earth")
            span { world.name }
          end
        end
      end
      if Rails.env.development? || current_user.admin?
        items << MenuItem.new do |content|
          content.link_item_to(admin_dashboard_path) do
            Icon("huge/wrench-01")
            span { "admin" }
          end
        end
      end
    end
    items
  end

  sig { returns(T::Array[MenuItem]) }
  def general_items
    items = T.let([], T::Array[MenuItem])
    unless hotwire_native_app?
      items << MenuItem.new do |content|
        content.link_item_to(root_path) do
          image_tag("logo.png", class: "size-4")
          span { "about smaller world" }
        end
      end
    end
    items << MenuItem.new do |content|
      content.link_item_to(new_contact_request_path) do
        Icon("huge/mail-01")
        span { "contact us" }
      end
    end
    items
  end
end
