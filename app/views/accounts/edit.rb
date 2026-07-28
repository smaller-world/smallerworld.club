# typed: strict
# frozen_string_literal: true

class Views::Accounts::Edit < Views::Base
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
      app_layout.page_container(
        class: "space-y-6 max-w-md",
      ) do
        unless hotwire_native_app?
          button_back_to(:home, variant: :secondary)
        end

        div(class: "flex flex-col gap-0.5") do
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
            class: "text-xs text-muted-foreground underline",
            target: "_blank",
            rel: "noopener",
          ) do
            "view our terms and policies"
          end
        end
      end
    end
  end
end
