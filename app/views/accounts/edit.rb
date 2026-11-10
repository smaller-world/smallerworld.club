# typed: strict
# frozen_string_literal: true

class Views::Accounts::Edit < Views::Base
  include Phlex::Rails::Helpers::FormWith

  # == Initialization ==

  sig { params(current_user: User).void }
  def initialize(current_user:)
    super()
    @current_user = current_user
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(title: "your account") do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        button_back_to(:home, variant: :secondary)
      end

      app_layout.page_container(class: "max-w-md flex-1") do
        div(class: "flex-1 flex flex-col gap-0.5") do
          Components::AccountForm(user: @current_user)
          Components::ConfirmDeleteButton(
            url: account_path,
            variant: :link,
            class: "self-center text-muted-foreground",
          ) do
            "delete account"
          end
        end

        div(class: "text-center") do
          link_to(
            policies_path,
            class: "text-xs text-muted-foreground underline self-center",
            target: "_blank",
            rel: "noopener",
          ) do
            "view our terms and policies"
          end
        end

        Components::Card() do |card|
          if (identifier = native_client_identifier)
            card.header do
              card.title(class: "font-mono text-xs text-center") do
                identifier
              end
            end
          end
          card.content(class: "space-y-4") do
            div(class: "flex flex-col gap-2") do
              span(class: "text-xs font-mono text-muted-foreground") do
                "user id"
              end
              Components::Input(
                type: :text,
                size: :xs,
                id: "user_id",
                value: @current_user.id,
                readonly: true,
                class: "text-xs font-mono",
                data: {
                  controller: "select-all",
                  action: "focus->select-all#select",
                },
              )
            end

            div(class: "flex flex-col gap-2") do
              span(class: "text-xs font-mono text-muted-foreground") do
                "has v1 account?"
              end
              div(class: "flex gap-2 justify-between items-start") do
                div(class: "flex gap-2") do
                  Components::Switch(
                    id: "has_v1_account",
                    checked: @current_user.has_v1_account?,
                    readonly: true,
                    class: "cursor-not-allowed"
                  )
                  Components::Label(for: "has_v1_account", class: "text-muted-foreground") do
                    @current_user.has_v1_account? ? "yep" : "nope"
                  end
                end
                if !@current_user.has_v1_account?
                  form_with(url: link_v1_account_path) do
                    Components::Button(type: :submit, size: :xs, variant: :ghost) do |button|
                        button.inline_start_icon("huge/refresh")
                        span { "re-check" }
                      end
                  end
                end
              end
            end

            if (device = Current.device)
              div(class: "flex flex-col gap-2") do
                span(class: "text-xs font-mono text-muted-foreground") do
                  "device identifier"
                end
                Components::Input(
                  type: :text,
                  size: :xs,
                  value: device.identifier,
                  readonly: true,
                  class: "text-xs font-mono",
                  data: {
                    controller: "select-all",
                    action: "focus->select-all#select",
                  },
                )
              end
            end
          end
        end
      end
    end
  end
end
