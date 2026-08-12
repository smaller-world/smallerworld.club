# typed: strict
# frozen_string_literal: true

class Components::WorldEnableNotificationsAlert < Components::Base
  include Phlex::Rails::Helpers::VideoTag

  # == Initialization ==

  sig do
    params(
      current_device: Device,
      title: String,
      attributes: T.untyped,
    ).void
  end
  def initialize(current_device:, title:, **attributes)
    super(**attributes)
    @current_device = current_device
    @title = title
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Alert(**mix(
      { class: "world-enable-notifications-alert" },
      @attributes,
    )) do |alert|
      Icon("huge/notification-01")
      alert.title do
        plain(@title)
      end
      Components::Dialog(data: {
        action: "notification-permission-bridge:authorized@document->dialog#close",
      }) do |dialog|
        dialog.with_trigger do
          Components::Form(
            @current_device,
            action: device_push_token_path,
            method: :put,
            class: "flex flex-col items-end",
            data: {
              controller: "device-push-token-form",
            },
          ) do |form|
            form.Field(:push_token).hidden(data: {
              device_push_token_form_target: "input",
            })
            form.submit(
              data: {
                controller: "notification-token-bridge",
                action: [
                  "notification-token-bridge#request:prevent",
                  "notification-token-bridge:retrieved->device-push-token-form#setInputValueAndSubmit",
                  "notification-token-bridge:denied->dialog#open",
                  "notification-permission-bridge:authorized@document->notification-token-bridge#request",
                ],
              },
            ) do |button|
              button.inline_start_icon(
                "huge/love-korean-finger",
                class: "[body[data-notification-permission=denied]_&]:hidden",
              )
              button.inline_start_icon(
                "huge/settings-01",
                class: "hidden [body[data-notification-permission=denied]_&]:revert-display-layer",
              )
              span { "enable notifications" }
            end
          end
        end
        dialog.with_content do |dialog_content|
          dialog_content.header do |dialog_header|
            dialog_header.title do
              "enable notifications in app settings"
            end
          end
          div(class: "flex flex-col gap-4") do
            div(class: "flex flex-col gap-2 my-4") do
              Components::Button(size: :lg, class: "self-center", data: {
                controller: "app-settings-bridge",
                action: "app-settings-bridge#open",
              }) do |button|
                button.inline_start_icon("huge/settings-01")
                span { "open app settings" }
              end
              span(class: "text-sm text-muted-foreground text-center") do
                "and enable notifications"
              end
            end
            video_tag(
              "enable_notifications_from_app_settings.mp4",
              playsinline: true,
              autoplay: true,
              muted: true,
              loop: true,
              class: "rounded-xl",
            )
          end
        end
      end
    end
  end
end
