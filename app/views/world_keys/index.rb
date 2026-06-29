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
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "your friends") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        div(class: "flex gap-6 justify-between", hidden: hotwire_native_app?) do
          button_back_to(@world.name, @world, variant: :secondary)
        end

        if (users = @current_user
            .accessible_world_owners_without_key_for(@world)
            .presence)
          invitations_items_for(users)
        end

        div(class: "flex flex-col gap-4 has-[[role=list]:empty]:hidden") do
          Components::ItemGroup(class: "gap-2") do
            @world.keys.each do |world_key|
              world_key_item(world_key)
            end
          end

          button_link_to(
            "give a key to a new friend",
            [ :new, @world, :key_grant ],
            variant: :default,
            size: :lg,
            icon: "huge/user-add-01",
            class: "self-center",
          )
        end

        Components::Empty(
          class: "hidden [:has([role=list]:empty)_+_&]:revert-display-layer",
        ) do |empty|
          empty.header do
            span(class: "font-emoji text-xl leading-none") { "😪" }
            empty.title do
              "nobody has access to your world!"
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

  sig { params(world_key: WorldKey).void }
  def world_key_item(world_key)
    recipient = world_key.recipient!
    Components::Item(variant: :muted, class: "flex-nowrap items-start") do |item|
      item.content do
        item.title do
          recipient.name
        end
      end

      item.actions(class: "items-start gap-2") do
        div(class: "flex items-center justify-end gap-0 flex-wrap ") do
          world_key.granted_post_types.secret.each do |post_type|
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

        div(class: "flex items-center gap-1") do
          if @world.post_types.secret.any?
            button_link_to(
              "edit key",
              [ :edit, world_key ],
              variant: :secondary,
              size: :xs,
              icon: "huge/key-02",
            )
          else
            Components::DropdownMenu() do |menu|
              menu.with_trigger_button(
                variant: :ghost,
                size: :icon_xs,
                class: "text-muted-foreground",
              ) do
                Icon("huge/delete-01")
              end
              menu.with_content(
                anchor: [ :bottom, :end ],
                class: "min-w-auto",
              ) do |menu_content|
                form_with(url: world_key, method: :delete) do
                  menu_content.button_item(type: :submit, variant: :destructive) do
                    Icon("huge/delete-01")
                    span { "destroy key" }
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  sig { params(users: User::PrivateAssociationRelation).void }
  def invitations_items_for(users)
    invitations_by_recipient_id = pending_invitations_by_recipient_id_for(users)
    Components::Item(variant: :muted, class: "gap-2") do |item|
      item.content do
        item.title do
          "these friends don't have access to your world: "
        end
      end
      item.footer(class: "justify-start gap-1.5") do
        users.find_each do |user|
          if (invitation = invitations_by_recipient_id[user.id])
            Components::DropdownMenu() do |menu|
              menu.with_trigger_button(variant: :outline, anchor: :bottom) do |button|
                button.inline_start_icon("huge/tick-01")
                span { user.name }
              end
              menu.with_content(class: "min-w-auto") do |content|
                content.label(class: "pt-1.5 pb-0.5 text-center") { "invitation sent!" }
                form_with(model: invitation, method: :delete) do
                  content.button_item(type: :submit, variant: :destructive) do
                    Icon("huge/mail-block-01")
                    span { "cancel invitation" }
                  end
                end
              end
            end
          elsif @world.post_types.secret.any?
            button_link_to(
              user.name,
              [ :new, @world, :invitation, recipient_id: user.id ],
              variant: :outline,
            )
          else
            Components::DropdownMenu() do |menu|
              menu.with_trigger_button(variant: :outline, anchor: :bottom) do
                user.name
              end
              menu.with_content(class: "min-w-auto") do |content; invitation|
                invitation = @world.invitations.build(recipient: user)
                form_with(model: invitation) do |form|
                  form.hidden_field(:recipient_id)
                  content.button_item(type: :submit) do
                    Icon("huge/mail-send-01")
                    span { "send invitation" }
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  sig do
    params(users: User::PrivateAssociationRelation)
      .returns(T::Hash[String, WorldInvitation])
  end
  def pending_invitations_by_recipient_id_for(users)
    @world.invitations.pending_acceptance.where(recipient: users).index_by do |invitation|
      T.must(invitation.recipient_id)
    end
  end
end
