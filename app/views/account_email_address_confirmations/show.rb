# typed: strict
# frozen_string_literal: true

class Views::AccountEmailAddressConfirmations::Show < Views::Base
  include Phlex::Rails::Helpers::FormWith

  # == Initialization ==

  sig { params(confirmation_token: String).void }
  def initialize(confirmation_token:)
    super()
    @confirmation_token = confirmation_token
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      title: ("confirm your email address" unless hotwire_native_app?),
      class: "bg-muted",
    ) do |app_layout|
      main(class: "flex-1 flex flex-col items-center justify-center") do
        app_layout.page_container(
          class: "flex flex-col items-center justify-center",
        ) do
          confirmation_card
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def confirmation_card
    Components::Card(class: "w-full max-w-90 gap-2.5") do |card|
      card.header(class: "flex flex-col items-center gap-2") do
        image_tag("logo.png", class: "size-10")
        card.title(class: "text-lg text-center") do
          "confirming your email address"
        end
      end
      card.content do
        confirmation_form
      end
    end
  end

  sig { void }
  def confirmation_form
    form_with(
      url: account_email_address_confirmation_path,
      method: :post,
      class: "flex flex-col items-center",
    ) do |form|
      form.hidden_field(:confirmation_token, value: @confirmation_token)

      Components::Button(
        type: :submit,
        class: "loading *:invisible",
        data: {
          controller: "autoclick",
          autoclick_once_value: true,
        },
      ) do |button|
        button.inline_start_icon("huge/checkmark-circle-01")
        span { "confirm your email address" }
      end
    end
  end
end
