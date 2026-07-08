# typed: strict
# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  include Phlex::Rails::Helpers::Pluralize

  # == Initialization ==

  sig { params(verification_request: PhoneNumberVerificationRequest).void }
  def initialize(verification_request:)
    super()
    @verification_request = verification_request
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      title: ("sign in to smaller world" unless hotwire_native_app?),
      body_class: "bg-muted [&_.flash]:bg-background",
      disable_cache: true,
    ) do |layout|
      layout.with_head do
        # JS for Cloudflare Turnstile
        link(rel: "preconnect", href: "https://challenges.cloudflare.com")
        script(
          src: "https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit&onload=onTurnstileLoad",
          async: true,
          defer: true,
        )
      end

      main(class: "flex-1 flex flex-col items-center justify-center") do
        layout.page_container(class: "flex flex-col items-center justify-center gap-6") do
          Components::Card(class: "w-full max-w-90 overflow-visible") do |card|
            card.header(class: "flex flex-col items-center gap-y-3") do
              image_tag("logo.png", class: "size-10")
              card.title(class: "text-lg text-center") do
                plain("sign in to ")
                span(class: "font-semibold") do
                  Smallerworld.application.site_name
                end
              end
            end
            card.content do
              Components::PhoneNumberVerificationForm(
                verification_request: @verification_request,
              )
            end
          end
        end
      end
    end
  end
end
