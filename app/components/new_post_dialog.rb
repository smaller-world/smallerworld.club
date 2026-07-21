# typed: strict
# frozen_string_literal: true

class Components::NewPostDialog < Components::Base
  include Phlex::Rails::Helpers::FormWith

  # == Initialization ==

  sig do
    params(
      world: World,
      open: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    world:,
    open: false,
    **attributes
  )
    super(**attributes)
    @world = world
    @open = open
  end

  # == Component ==

  sig { override.params(content: T.proc.params(dialog: Components::Dialog).void).void }
  def view_template(&content)
    Components::Dialog(
      open: @open,
      data: {
        controller: "world-new-post-dialog",
        action: [
          "open->world-new-post-dialog#updateSearchParams",
          "close->world-new-post-dialog#updateSearchParams",
          "cancel->world-new-post-dialog#updateSearchParams",
        ],
      },
    ) do |dialog|
      yield dialog
      dialog.with_content do |dialog_content|
        dialog_content.header do |dialog_header|
          dialog_header.title do
            "what do you want to write?"
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
            class: "hidden group-data-[draft-available]/item-group:revert-display-layer mb-2",
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

          @world.post_types.chronological.each do |post_type|
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
                  action: "redirect-back-to-self#visit dialog#close",
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
              action: "redirect-back-to-self#visit dialog#close",
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
end
