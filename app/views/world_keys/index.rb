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
      @world.keys.includes(:recipient, :type),
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
      turbo_stream_from(@world, :keys, hidden: true)

      app_layout.with_navigation(class: "max-w-md") do
        button_back_to(@world.name, @world, variant: :secondary)
        button_link_to(
          "edit key types",
          [ @world, :key_types ],
          variant: :secondary,
          icon: "huge/settings-01",
          data: {
            controller: "button-bridge",
            bridge_ios_image: "gearshape.fill",
            bridge_android_image: "settings",
          },
        )
      end

      app_layout.page_container(class: "max-w-md") do
        if @invitable_users.any?
          invitations_item
        end

        if @world_keys.any?
          Components::ItemGroup() do |item_group|
            @world_keys.each do |world_key|
              item_group.item(
                element: :a,
                href: url_for([ :new, @world, :key_grant ]),
                variant: :muted,
                size: :sm,
              ) do |item|
                item.media(variant: :icon) do
                  Icon("huge/plus-sign-square")
                end
                item.content(class: "gap-0") do |item_content|
                  item_content.title do
                    "add a friend"
                  end
                end
              end
              div
              world_key_item(world_key)
            end
          end
        else
          Components::Empty() do |empty|
            empty.header(class: "gap-0") do
              empty.media do
                span(class: "font-emoji text-xl leading-none") { "😪" }
              end
              empty.title(class: "flex flex-col gap-2") do
                span { "nobody has access to your world!" }
              end
              empty.description do
                "you haven't added any friends yet"
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
    type = world_key.type!
    Components::Item(
      variant: :outline,
      class: "flex-nowrap items-start gap-2",
    ) do |item|
      item.content(class: "flex-row items-center gap-2") do |item_content|
        item_content.title do
          recipient.name
        end
        item_content.description do
          Components::Badge(
            variant: :ghost,
            class: "text-key-foreground",
            data: {
              key_color: type.color,
            },
          ) do |badge|
            badge.inline_start_icon("huge/key-02")
            span { type.name }
          end
        end
      end

      item.actions do
        button_link_to(
          "edit key",
          [ :edit, world_key ],
          variant: :secondary,
          size: :xs,
          icon: "huge/edit-02",
        )
      end
    end
  end

  sig { void }
  def invitations_item
    Components::Item(variant: :muted, class: "gap-2") do |item|
      item.content do |item_content|
        item_content.title do
          "these friends don't have access (yet) to your world: "
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
