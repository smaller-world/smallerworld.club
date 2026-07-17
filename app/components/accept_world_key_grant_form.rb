# typed: strict
# frozen_string_literal: true

class Components::AcceptWorldKeyGrantForm < Components::Base
  # == Initialization ==

  sig do
    params(
      verified_grant: VerifiedWorldKeyGrant,
      invitation: WorldInvitation,
      attributes: T.untyped,
    ).void
  end
  def initialize(verified_grant:, invitation:, **attributes)
    super(**attributes)
    @verified_grant = verified_grant
    @invitation = invitation
    @world = T.let(@verified_grant.world, World)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @invitation,
      id: "accept_world_key_grant_form",
      action: accept_world_key_grant_path(message: @verified_grant.grant_message),
      **@attributes,
    ) do |form|
      Components::Card(
        size: :sm,
        class: class_names("contents" => Current.user),
      ) do |card|
        unless Current.user
          card.header do
            card.title do
              "it looks like you're not on the app yet!"
            end
            card.description do
              "add your phone #, and we'll save this invitation to your account—you'll " \
                "see it when you sign in to the app :)"
            end
          end
        end
        card.content(class: Current.user ? "contents" : "flex flex-col gap-2.5 pb-1") do
          unless Current.user
            form.wrapped(
              form.field(:recipient_phone_number).phone_number(
                placeholder: "your phone #",
                class: "max-w-72 mx-auto",
              ),
              label: false,
              error: { class: "text-center" },
            )
          end

          if invitation_accepted?
            span(class: "text-muted-foreground text-center") do
              "your invitation has been saved."
            end
          else
            form.submit(
              size: Current.user ? :lg : :default,
              class: "self-center",
            ) do |button|
              if Current.user
                button.inline_start_icon("huge/door-01")
                span { "enter #{@world.name}" }
              else
                button.inline_start_icon("huge/bookmark-02")
                span { "save my invitation!" }
              end
            end
          end

          if invitation_accepted?
            button_link_to(
              "next, download the app!",
              installation_instructions_path,
              variant: :default,
              icon: "huge/app-store",
              class: "self-center mt-2",
            )
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def invitation_accepted?
    @invitation.persisted? && @invitation.valid?
  end
end
