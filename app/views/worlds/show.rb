# typed: strict
# frozen_string_literal: true

class Views::Worlds::Show < Views::Base
  include Phlex::Rails::Helpers::FormWith

  # == Initialization ==

  sig do
    params(
      current_user: User,
      world: World,
      celebrate: T::Boolean,
      new_post_dialog_open: T::Boolean,
      selected_post_type: T.nilable(PostType),
      created_post_id: T.nilable(String),
    ).void
  end
  def initialize(
    current_user:,
    world:,
    celebrate:,
    new_post_dialog_open:,
    selected_post_type:,
    created_post_id:
  )
    super()
    @current_user = current_user
    @world = world
    @celebrate = celebrate
    @new_post_dialog_open = new_post_dialog_open
    @selected_post_type = selected_post_type
    @created_post_id = created_post_id

    @owner = T.let(@world.owner!, User)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: @world.name) do |app_layout|
      app_layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        navigation_buttons

        world_invitation_alert
        v1_post_import_frame

        div(class: "flex flex-col gap-6") do
          section(class: "flex flex-col items-center gap-2") do
            div(class: "relative") do
              image_tag(
                @world.page_icon_variant,
                id: dom_id(@world, :page_icon),
                class: "world-icon size-32",
                data: {
                  turbo_permanent: true,
                  controller: "confetti connection",
                  confetti_emoji_value: "🎉",
                  confetti_canvas_id_value: Rails.configuration.confetti_canvas_id,
                  connection_delay_value: 1000,
                  action: ("turbo:load@document->confetti#launch" if @celebrate),
                },
              )
              if allowed_to?(:manage?, @world)
                Components::WorldKeyGrantIconButton(world: @world)
              end
            end
            h1(class: "text-2xl text-center") do
              @world.name
            end
            if (blurb = @world.blurb)
              p(class: "whitespace-pre-wrap text-center text-muted-foreground text-sm") do
                blurb
              end
            end
          end

          if allowed_to?(:manage?, @world)
            section(class: "flex gap-2 justify-center") do
              new_post_button
              button_link_to(
                "your friends",
                [ @world, :keys ],
                variant: :outline,
                size: :lg,
                icon: "huge/user-group",
                class: "world-action-button",
              )
            end
          end
        end

        div(class: "flex flex-col gap-4") do
          Components::WorldPostTypeForm(world: @world, selected_post_type: @selected_post_type)

          turbo_frame_tag(
            @world,
            :posts,
            src: [
              @world,
              :posts,
              type_id: @selected_post_type&.id,
              created_post_id: @created_post_id,
            ],
            target: "_top",
            class: "world-posts-frame",
            data: {
              turbo_permanent: (true if hotwire_native_app?),
            },
          ) do
            div(class: "space-y-4") do
              3.times do
                Components::PostCardSkeleton()
              end
            end
          end
        end
      end

      if @world_key
        Components::WorldKeyWorldVisitForm(world_key: @world_key)
      else
        Components::AccountAppVisitForm(current_user: @current_user)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(WorldKey)) }
  def world_key
    @world_key = T.let(
      @world.keys.find_by(recipient: @current_user),
      T.nilable(WorldKey),
    )
  end

  sig { void }
  def navigation_buttons
    div(class: "flex gap-6 justify-between", hidden: hotwire_native_app?) do
      button_back_to(:home, variant: :secondary)

      if allowed_to?(:manage?, @world)
        button_link_to(
          "edit",
          [ :edit, @world ],
          icon: "huge/pencil-edit-01",
          variant: :secondary,
          data: {
            controller: "button-bridge",
          },
        )
      elsif (world_key = self.world_key)
        button_link_to(
          "settings",
          world_key,
          variant: :secondary,
          icon: "huge/settings-01",
          data: {
            controller: "button-bridge",
            bridge_ios_image: "gearshape.fill",
          },
        )
      end
    end
  end

  sig { void }
  def world_invitation_alert
    if @current_user != @owner &&
        (worlds = @current_user
          .owned_worlds_without_key_or_invitation_for(@owner)
          .to_a.presence) &&
        worlds.size == @current_user.owned_worlds.size
      Components::Item(variant: :muted, class: "gap-2") do |item|
        item.content(class: "gap-0.5") do |item_content|
          item_content.title do
            "you can #{@owner.name}'s posts, but #{@owner.name} can't see yours!"
          end
          description_html = capture do
            item_content.description do
              "give #{@owner.name} a key to your world?"
            end
          end
          primary_world, *other_worlds = worlds
          primary_world = T.must(primary_world)
          if other_worlds.none?
            link_to(
              [ :new, primary_world, :invitation, recipient_id: @owner.id ],
              class: "underline",
              data: {
                controller: "redirect-back-to-self",
                action: "redirect-back-to-self#visit:prevent",
              },
            ) do
              raw(description_html) # rubocop:disable Rails/OutputSafety
            end
          else
            Components::Dialog() do |dialog|
              dialog.with_trigger do
                button(
                  data: { action: "dialog#open" },
                  class: "text-muted-foreground underline",
                ) do
                  raw(description_html) # rubocop:disable Rails/OutputSafety
                end
              end
              dialog.with_content do |dialog_content|
                dialog_content.header do |dialog_header|
                  dialog_header.title do
                    "give #{@owner.name} a key to your world!"
                  end
                end

                div(class: "space-y-3") do
                  div(class: "text-sm") do
                    "pick the world you'd like to invite #{@owner.name} to:"
                  end
                  Components::ItemGroup() do |group|
                    worlds.each do |world|
                      group.item(
                        element: :a,
                        href: url_for([
                          :new,
                          world,
                          :invitation,
                          recipient_id: @owner.id,
                        ]),
                        variant: :outline,
                        size: :sm,
                        data: {
                          controller: "redirect-back-to-self",
                          action: "redirect-back-to-self#visit:prevent",
                        },
                      ) do |item|
                        item.media(variant: :image, class: "size-14 rounded-world-icon") do
                          image_tag(world.page_icon_variant)
                        end
                        item.content(class: "gap-0.5") do |item_content|
                          item_content.title(class: "text-base font-heading") do
                            world.name
                          end
                          if (blurb = world.blurb)
                            item_content.description(class: "text-xs") do
                              blurb
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  sig { void }
  def v1_post_import_frame
    if allowed_to?(:manage?, @world) && @owner.has_v1_account?
      turbo_frame_tag(
        :v1_posts_import,
        src: [ @world, :v1_posts_import ],
        class: "empty:hidden pb-2",
        data: {
          controller: "frame-reload frame-reset user-focus",
        },
      )
      turbo_stream_from(@world, :v1_posts_import, hidden: true)
    end
  end

  sig { void }
  def new_post_button
    Components::Dialog(
      open: @new_post_dialog_open,
      data: {
        controller: "world-new-post-dialog",
        action: [
          "open->world-new-post-dialog#updateSearchParams",
          "close->world-new-post-dialog#updateSearchParams",
          "cancel->world-new-post-dialog#updateSearchParams",
        ],
      },
    ) do |dialog|
      dialog.with_trigger_button(
        size: :lg,
        class: "world-action-button group/new-post-button relative",
        data: {
          controller: "post-draft-info",
          post_draft_info_world_id_value: @world.id,
          action: "user-focus:active@document->post-draft-info#update",
        },
      ) do |button|
        button.inline_start_icon(
          "huge/quill-write-02",
          class: "group-data-draft-available/new-post-button:hidden",
        )
        button.inline_start_icon(
          "huge/more-horizontal-circle-02",
          class: "hidden group-data-draft-available/new-post-button:revert-display-layer",
        )
        span { "new post" }
      end
      dialog.with_content do |dialog_content|
        dialog_content.header do |dialog_header|
          dialog_header.title do
            "what do you want to make?"
          end
        end

        Components::ItemGroup(
          data: {
            controller: "post-draft-info intersection",
            post_draft_info_world_id_value: @world.id,
            action: "intersection:appear->post-draft-info#update",
          },
        ) do |item_group|
          form_with(
            url: [ :new, @world, :post ],
            method: :get,
            class: "hidden group-data-[draft-available]/item-group:revert-display-layer",
          ) do |form|
            form.hidden_field(:type_id, data: {
              post_draft_info_target: "typeIdInput",
            })
            form.hidden_field(:restore_draft, value: true)
            item_group.item(
              element: :button,
              type: :submit,
              size: :sm,
              class: "bg-primary text-primary-foreground transition-colors hover:bg-primary/80",
              data: {
                action: "dialog#close",
              },
            ) do |item|
              item.content do |item_content|
                item_content.title do
                  "continue from draft?"
                end
                item_content.description(
                  class: "empty:hidden text-primary-foreground/80 border-l-2 border-border/50 pl-3 italic",
                  data: {
                    post_draft_info_target: "descriptionLabel",
                  },
                )
              end
            end
          end
          item_group.separator(
            class: "hidden [form[data-draft-available]+&]:revert-display-layer",
          )

          @world.post_types.each do |post_type|
            div(class: "flex items-center gap-1") do
              item_group.item(
                element: :a,
                href: url_for([ :new, @world, :post, type_id: post_type.id ]),
                variant: :outline,
                size: :sm,
                data: {
                  action: "dialog#close",
                },
              ) do |item|
                item.media(variant: :icon) do
                  Icon(post_type.icon)
                end
                item.content do |item_content|
                  item_content.title do
                    post_type.label
                  end
                end
              end
              button_link_to(
                "edit",
                [ :edit, post_type ],
                size: :sm,
                class: "text-muted-foreground",
                data: {
                  controller: "redirect-back-to-self",
                  action: "redirect-back-to-self#visit:prevent dialog#close",
                },
              )
            end
          end

          div

          item_group.item(
            element: :a,
            href: url_for([ :new, @world, :post_type ]),
            variant: :muted,
            size: :sm,
            data: {
              controller: "redirect-back-to-self",
              action: "redirect-back-to-self#visit:prevent dialog#close",
            },
          ) do |item|
            item.content(class: "gap-0") do |item_content|
              item_content.title do
                "something else!"
              end
              item_content.description do
                "create your own post type"
              end
            end
          end
        end
      end
    end
  end

  # sig { params(cards: WorldCard::PrivateRelation).void }
  # def unclaimed_world_cards(cards)
  #   Components::ItemGroup(
  #     class: "hidden",
  #     data: {
  #       controller: "transition-group transition connection",
  #       transition_group_target: "item",
  #       transition_enter: "transition-[max-height] duration-400 ease-in-quart",
  #       transition_enter_start: "max-h-0",
  #       transition_enter_end: "max-h-[1000px]",
  #       action: [
  #         "transition:transitioned->transition-group#startNext",
  #         "connection:connect->transition#enter",
  #       ],
  #     },
  #   ) do
  #     cards.find_each do |card|
  #       Components::Item(
  #         variant: :muted,
  #         size: :sm,
  #         class: "gap-y-2 hidden [&.hidden]:scale-95",
  #         data: {
  #           hidden_inline: true,
  #           transition_group_target: "item",
  #           controller: "transition",
  #           transition_enter: "transition-[opacity,scale] ease-in",
  #           transition_enter_start: "scale-95",
  #           action: [
  #             "transition-group:start->transition#enter",
  #             "transition:transitioned->transition-group#startNext",
  #           ],
  #         },
  #       ) do |item|
  #         item.media do
  #           Icon("huge/loyalty-card", class: "size-5")
  #         end
  #         item.content(class: "gap-0") do
  #           item.title do
  #             "you have an unlinked card for #{@world.name}"
  #           end
  #           item.description(class: "flex gap-1") do
  #             plain("card id:")
  #             span(class: "font-mono") { card.short_id }
  #           end
  #         end
  #         item.actions(class: "mx-auto") do
  #           form_with(model: [ :claim, card ], method: :post) do |form|
  #             submit_button_for(form, size: :sm) do |button|
  #               button.inline_start_icon("huge/link-01")
  #               span { "claim card" }
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end if cards.any?
  # end

  # sig { params(card: WorldCard).void }
  # def card_icon_button(card)
  #   Components::Button(
  #     variant: :outline,
  #     size: :icon_sm,
  #     class: [
  #       "bg-muted rounded-full absolute -right-2.5 -top-2.5",
  #       "hidden with-pass-bridge:revert-display-layer",
  #     ],
  #     data: {
  #       controller: "pass-bridge",
  #       pass_bridge_pass_type_identifier_value:
  #         Smallerworld.application.passkit_pass_type_identifier,
  #       pass_bridge_serial_number_value: card.pass!.serial_number,
  #       action: "pass-bridge#open",
  #     },
  #   ) do
  #     Icon(
  #       "huge/loyalty-card",
  #       class: "text-muted-foreground",
  #     )
  #   end
  # end
end
