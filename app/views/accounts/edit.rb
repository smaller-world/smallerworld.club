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
        class: "flex flex-col gap-6 max-w-md",
      ) do
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
        link_to(
          policies_path,
          class: "mx-auto text-xs text-muted-foreground underline",
          target: "_blank",
          rel: "noopener",
        ) do
          "our terms and policies"
        end
      end
    end
  end
end
