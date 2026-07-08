# typed: strict
# frozen_string_literal: true

class Views::Accounts::New < Views::Base
  # == Initialization ==

  sig { params(user: User).void }
  def initialize(user:)
    super()
    @user = user
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      title: "create account",
      body_class: "bg-muted",
    ) do |app_layout|
      app_layout.page_container(
        class: "flex-1 flex flex-col items-center justify-center",
      ) do
        account_card
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def account_card
    Components::Card(class: "w-full max-w-90") do |card|
      card.header(class: "flex flex-col items-center gap-2") do
        image_tag("logo.png", class: "size-10")
        card.title(class: "text-lg text-center") do
          plain("welcome to ")
          span(class: "font-semibold") do
            Smallerworld.application.site_name
          end
        end
      end
      card.content do
        Components::AccountForm(user: @user)
      end
    end
  end
end
