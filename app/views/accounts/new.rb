# typed: true
# frozen_string_literal: true

class Views::Accounts::New < Views::Base
  # == Initialization ==

  sig { params(user: User).void }
  def initialize(user:)
    @user = user
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(
      title: "create account",
      body_class: "bg-muted",
    ) do |layout|
      main(class: "flex-1 flex flex-col justify-center pb-20") do
        layout.page_container(
          class: "flex flex-col items-center justify-center",
        ) do
          account_card
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def account_card
    Components::Card(class: "w-full max-w-xs") do |card|
      card.header(class: "flex flex-col items-center gap-y-3") do
        image_tag("logo.png", class: "size-10")
        card.title(class: "text-lg text-center") do
          "join smaller world"
        end
      end
      card.content(class: "flex flex-col items-stretch gap-y-3") do
        Components::AccountForm(user: @user)
      end
    end
  end
end
