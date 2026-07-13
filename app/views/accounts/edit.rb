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
    Components::AppLayout(
      title: "your account",
      body_class: "bg-muted",
    ) do |app_layout|
      app_layout.page_container(
        class: "flex-1 flex flex-col max-w-md",
      ) do
        Components::AccountForm(user: @current_user)
      end
    end
  end
end
