# typed: strict
# frozen_string_literal: true

class Components::WorldPostFiltersForm < Components::Base
  # == Initialization ==

  sig do
    params(
      world: World,
      currently_showing_favorited: T::Boolean,
      current_post_type: T.nilable(PostType),
      attributes: T.untyped,
    ).void
  end
  def initialize(world:, currently_showing_favorited:, current_post_type:, **attributes)
    super(**attributes)
    @world = world
    @current_post_type = current_post_type
    @currently_showing_favorited = currently_showing_favorited
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
        controller: "world-post-filters-form",
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
              action: "event#stopPropagation redirect-back-to-self#visit",
            }) do
              Icon("huge/settings-01")
            end
            choice.input(
              name: "type_id",
              checked: choice.item == @current_post_type,
              class: "visually-hidden",
              toggleable: true,
              data: {
                action: "world-post-filters-form#updateSearchParamsAndSubmit",
              },
            )
          end
        end
      end

      if allowed_to?(:manage?, @world) && @world.posts.favorited.any?
        form.label_for(:favorited, class: "world-only-favorited-label") do
          Components::Field(
            orientation: :horizontal,
            class: "badge",
            data: {
              variant: "ghost",
              controller: "tooltip",
              tooltip_content_value: "show only your starred posts",
            },
          ) do
            Icon("huge/star")
            form.Field(:favorited).checkbox(
              checked: @currently_showing_favorited,
              class: "visually-hidden",
              name: "favorited",
              data: {
                action: "world-post-filters-form#updateSearchParamsAndSubmit",
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
    unless @currently_showing_favorited
      options[:only_favorited] = true
    end
    world_url(@world, **options)
  end
end
