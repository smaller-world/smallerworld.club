# typed: true
# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  include Phlex::Rails::Helpers::ButtonTo

  # == Initialization ==

  sig { params(verification_request: PhoneNumberVerificationRequest).void }
  def initialize(verification_request:)
    @verification_request = verification_request
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(
      title: "sign in to smaller world",
      body_class: "bg-muted [&_.flash]:bg-background",
    ) do |layout|
      main(class: "flex-1 flex flex-col justify-center pb-20") do
        layout.page_container(
          class: "flex flex-col items-center justify-center",
        ) do
          login_card
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def login_card
    Components::Card(class: "w-full max-w-xs") do |card|
      card.header(class: "flex flex-col items-center gap-y-3") do
        image_tag("logo.png", class: "size-10")
        card.title(class: "text-lg text-center") do
          if (site_name = Rails.configuration.x.site.name)
            plain("sign in to ")
            span(class: "font-semibold") { site_name }
          else
            plain("sign in")
          end
        end
      end
      card.content(class: "flex flex-col items-stretch gap-y-3") do
        Components::PhoneNumberVerificationRequestForm(
          verification_request: @verification_request,
        )
        # Components::SignInWithAppleButton()
        # Components::SignInWithGoogleButton()
        # if Rails.env.development? && (users = User.all.presence)
        #   Components::DropdownMenu(anchor: :bottom, class: "mx-auto") do |menu|
        #     menu.trigger do
        #       Components::Button(
        #         variant: :link,
        #         class: "text-muted-foreground",
        #       ) do
        #         "[development] sign in as..."
        #       end
        #     end
        #     menu.content do
        #       users.find_each do |user|
        #         button_to(
        #           user.email_address_with_name,
        #           session_path,
        #           params: { user_id: user.id },
        #           **menu.item_attributes,
        #         )
        #       end
        #     end
        #   end
        # end
      end
    end
  end
end
