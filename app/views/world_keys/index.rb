# typed: strict
# frozen_string_literal: true

class Views::WorldKeys::Index < Views::Base
  include Phlex::Rails::Helpers::Pluralize

  # == Initialization ==

  sig { params(current_user: User, world: World).void }
  def initialize(current_user:, world:)
    super()
    @current_user = current_user
    @world = world
    @world_keys = T.let(
      @world.keys.includes(:recipient, :granted_post_types),
      WorldKey::PrivateAssociationRelation,
    )
    @invitable_users = T.let(
      @current_user.accessible_world_owners_without_key_for(@world),
      User::PrivateAssociationRelation,
    )
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "your friends") do |app_layout|
      app_layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        div(class: "flex gap-6 justify-between", hidden: hotwire_native_app?) do
          button_back_to(@world.name, @world, variant: :secondary)
          button_link_to(
            "give a key to a new friend",
            [ :new, @world, :key_grant ],
            variant: :default,
            icon: "huge/user-add-01",
            class: "self-center",
            data: {
              controller: "button-bridge",
              bridge_ios_image: "person.crop.circle.fill.badge.plus",
              bridge_android_image: "person_add",
            },
          )
        end

        if @invitable_users.any?
          invitations_item
        end

        Components::ItemGroup(class: "empty:hidden") do
          @world_keys.each do |world_key|
            world_key_item(world_key)
          end
        end

        Components::Empty(
          class: "hidden [:has([role=list]:empty)+&]:revert-display-layer",
        ) do |empty|
          empty.header(class: "gap-0") do
            empty.media do
              span(class: "font-emoji text-xl leading-none") { "😪" }
            end
            empty.title(class: "flex flex-col gap-2") do
              span { "nobody has access to your world!" }
            end
            empty.description do
              "you haven't shared any world keys with anyone yet"
            end
          end
          empty.content do
            button_link_to(
              "give a friend a key to your world",
              [ :new, @world, :key_grant ],
              variant: :default,
              icon: "huge/user-add-01",
            )
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Hash[String, WorldInvitation]) }
  def pending_invitations_by_recipient_id
    @pending_invitations_by_recipient_id ||= T.let(
      @world.invitations.pending_acceptance.where(recipient: @invitable_users)
        .index_by do |invitation|
          T.must(invitation.recipient_id)
        end,
      T.nilable(T::Hash[String, WorldInvitation]),
    )
  end

  sig { params(recipient: User).returns(T.nilable(WorldInvitation)) }
  def pending_invitation_for(recipient:)
    pending_invitations_by_recipient_id[recipient.id]
  end

  sig { params(world_key: WorldKey).void }
  def world_key_item(world_key)
    recipient = world_key.recipient!
    Components::Item(
      variant: :muted,
      class: "flex-nowrap items-start gap-2",
    ) do |item|
      item.content(class: "flex-row items-start") do |item_content|
        item_content.title do
          recipient.name
        end
        item_content.description(
          class: "flex-1 flex items-center justify-end gap-0.5 flex-wrap",
        ) do
          world_key.granted_post_types.each do |post_type|
            Components::Badge(
              variant: :ghost,
              class: "text-muted-foreground",
            ) do |badge|
              if (icon = post_type.icon)
                badge.inline_start_icon(icon)
              end
              span { post_type.label }
            end
          end
        end
      end

      item.actions do
        button_link_to(
          "edit key",
          [ :edit, world_key ],
          variant: :secondary,
          size: :xs,
          icon: "huge/key-02",
        )
      end
    end
  end

  sig { void }
  def invitations_item
    Components::Item(variant: :muted, class: "gap-2") do |item|
      item.content do |item_content|
        item_content.title do
          "these friends don't have access to your world: "
        end
      end
      item.footer(class: "justify-start") do
        @invitable_users
          .partition { |user| pending_invitation_for(recipient: user).nil? }
          .flatten.each do |user|
          if (invitation = pending_invitation_for(recipient: user))
            Components::DropdownMenu() do |menu|
              menu.with_trigger_button(
                variant: :ghost,
                anchor: :bottom,
                class: "font-normal border-border",
              ) do |button|
                button.inline_start_icon("huge/tick-01")
                span { user.name }
              end
              menu.with_content do |menu_content|
                menu_content.link_item_to([ :edit, invitation ]) do
                  Icon("huge/pencil-edit-01")
                  span { "edit invitation" }
                end
                Components::Form(invitation, method: :delete) do
                  menu_content.button_item(type: :submit, variant: :destructive) do
                    Icon("huge/delete-01")
                    span { "cancel invitation" }
                  end
                end
              end
            end
          else
            button_link_to(
              user.name,
              [ :new, @world, :invitation, recipient_id: user.id ],
              variant: :outline,
              class: "font-normal",
            )
          end
        end
      end
    end
  end
end
