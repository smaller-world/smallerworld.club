# typed: strict
# frozen_string_literal: true

class Views::ContactRequests::New < Views::Base
  include Phlex::Rails::Helpers::FormWith

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      page_title: "contact smaller world",
      class: "bg-muted [&_.flash]:bg-background",
    ) do |app_layout|
      if hotwire_native_app?
        app_layout.page_container do
          contact_request_form
        end
      else
        main(class: "flex-1 flex flex-col items-center justify-center") do
          Components::Card(class: "w-full max-w-90") do |card|
            card.header(class: "text-center") do
              card.title(class: "text-lg text-center") do
                "contact smaller world :)"
              end
              card.description do
                "let us know how we can help!"
              end
            end
            card.content do
              contact_request_form
            end
          end
        end
      end
    end

    div(id: "contact_links")
  end

  private

  # == Helpers ==

  sig { void }
  def contact_request_form
    form_with(
      url: contact_request_path,
      method: :post,
      class: "flex flex-col items-center gap-2.5",
    ) do
      Components::Button(
        type: :submit,
        name: "purpose",
        value: "support",
        size: :lg,
      ) do |button|
        button.inline_start_icon("huge/alert-diamond")
        span { "i'm having an issue with smaller world" }
      end
      Components::Button(
        type: :submit,
        variant: :outline,
        name: "purpose",
        value: "inquiry",
        size: :lg,
      ) do |button|
        button.inline_start_icon("huge/waving-hand-01")
        span { "i'd like to send a message to the team" }
      end
    end
  end
end
