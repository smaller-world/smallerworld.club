# typed: strict
# frozen_string_literal: true

class Components::AcceptWorldKeyGrantForm < Components::Base
  # == Initialization ==

  sig { params(world: World, grant: String, invitation: WorldInvitation, attributes: T.untyped).void }
  def initialize(world:, grant:, invitation:, **attributes)
    super(**attributes)
    @world = world
    @grant = grant
    @invitation = invitation
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      id: :accept_world_key_grant_form,
      model: @invitation,
      url: accept_world_key_grant_path(grant: @grant),
      **@attributes,
    ) do |form|
      Components::Card(
        size: :sm,
        class: class_names("min-w-sm", "contents" => Current.user),
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
            field_for(form, :recipient_phone_number, class: "max-w-72 mx-auto") do |f|
              f.phone_number_input(
                placeholder: "your phone #",
                disabled: invitation_accepted?,
              )
              f.error(class: "text-center")
            end
          end

          if invitation_accepted?
            span(class: "text-muted-foreground text-center") do
              "your invitation has been saved."
            end
          else
            submit_button_for(
              form,
              size: Current.user ? :lg : :default,
              class: "self-center",
              disabled: invitation_accepted?,
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
              appstore_listing_path,
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
