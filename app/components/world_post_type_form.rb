# typed: strict
# frozen_string_literal: true

class Components::WorldPostTypeForm < Components::Base
  # == Initialization ==

  sig do
    params(
      world: World,
      selected_post_type: T.nilable(PostType),
      showing_favorites: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(world:, selected_post_type:, showing_favorites:, **attributes)
    super(**attributes)
    @world = world
    @selected_post_type = selected_post_type
    @showing_favorites = showing_favorites
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @world,
      action: [ @world, :posts ],
      method: :get,
      class: "flex-row items-start gap-2",
      data: {
        turbo_frame: dom_id(@world, :posts),
        controller: "world-post-type-form",
      },
    ) do |form|
      form.Field(:type_id).radios(
        post_types,
        class: "flex justify-center gap-0.5 flex-wrap",
      ) do |choice|
        choice.label(class: "world-post-type-choice-label") do
          Components::Field(
            orientation: :horizontal,
            class: "badge font-normal",
            data: {
              variant: "ghost",
            },
          ) do
            Icon(choice.item.icon, data: { icon: :inline_start })
            span do
              choice.item.label
            end
            button_link_to([ :edit, choice.item ], size: :icon_xs, data: {
              controller: "event redirect-back-to-self",
              action: "event#stopPropagation redirect-back-to-self#visit:prevent",
            }) do
              Icon("huge/settings-01")
            end
            choice.input(
              name: "type_id",
              checked: choice.item == @selected_post_type,
              class: "visually-hidden",
              toggleable: true,
              data: {
                action: "world-post-type-form#updateSearchParamsAndSubmit",
              },
            )
          end
        end
      end

      if allowed_to?(:manage?, @world) && @world.posts.favorited.any?
        form.label_for(:only_favorited, class: "world-only-favorited-label") do
          Components::Field(
            orientation: :horizontal,
            class: "badge",
            data: {
              variant: "secondary",
            },
          ) do
            Icon("huge/star")
            form.Field(:only_favorited).checkbox(
              checked: @showing_favorites,
              class: "visually-hidden",
              name: "only_favorited",
              data: {
                action: "world-post-type-form#updateSearchParamsAndSubmit",
              },
            )
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(PostType::PrivateAssociationRelation) }
  def post_types
    authorized_scope(@world.post_types).chronological
  end

  sig { returns(String) }
  def favorited_world_url
    options = {}
    unless @showing_favorites
      options[:only_favorited] = true
    end
    world_url(@world, **options)
  end
end
