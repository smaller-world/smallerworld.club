# typed: strict
# frozen_string_literal: true

class Components::AppHeader < Components::Base
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    logo_button_options = { variant: :ghost, class: "gap-x-1.5" }

    root_element(:header, class: "flex justify-center py-2") do
      if authenticated?
        Components::DropdownMenu() do |menu|
          menu.with_trigger_button(**logo_button_options) do
            logo_button_content
          end

          menu.with_content(anchor: :bottom, class: "w-56") do |content|
            menu_content(content)
          end
        end
      else
        button_link_to(root_path, **logo_button_options) do
          logo_button_content
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def logo_button_content
    site_name = Smallerworld.application.site_name

    image_tag(
      "logo.png",
      alt: [ site_name, "logo" ].join(" "),
      class: "size-6",
      data: {
        icon: "inline-start",
      },
    )

    span(class: "font-heading font-semibold text-lg") do
      site_name
    end
  end

  sig { params(content: Components::DropdownMenu::Content).void }
  def menu_content(content)
    if @current_device
      form_with(url: test_device_push_token_path, data: {
        controller: "haptic-bridge",
        action: "turbo:submit-end->haptic-bridge#vibrate",
      }) do
        content.button_item(type: :submit) do
          Icon("huge/notification-01")
          span { "send test notification" }
        end
      end
      content.separator
    elsif !hotwire_native_app?
      content.group do
        # content.label { "[some group]" }
        content.link_item_to(:home) do
          Icon("huge/home-01")
          span { "home" }
        end
        if (world = @current_user&.owned_worlds&.chronological&.first)
          content.link_item_to(world) do
            Icon("huge/earth")
            span { world.name }
          end
        end
        # content.button_item { "[some item]" }
      end
      content.separator
    end

    form_with(url: session_path, method: :delete, data: {
      controller: "haptic-bridge",
      action: "turbo:submit-end->haptic-bridge#vibrate",
    }) do
      content.button_item(type: :submit, variant: :destructive) do
        Icon("huge/logout-01")
        span { "sign out" }
      end
      # if Rails.env.development?
      #   content.separator
      #   # ...
      # end
    end
  end
end
