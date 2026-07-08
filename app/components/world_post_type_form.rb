# typed: true
# frozen_string_literal: true

class Components::WorldPostTypeForm < Components::Base
  # == Initialization ==

  sig do
    params(
      world: World,
      selected_post_type: T.nilable(PostType),
      attributes: T.untyped,
    ).void
  end
  def initialize(world:, selected_post_type:, **attributes)
    super(**attributes)
    @world = world
    @selected_post_type = selected_post_type
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @world,
      action: [ @world, :posts ],
      method: :get,
      data: {
        turbo_frame: dom_id(@world, :posts),
        controller: "submit",
      },
    ) do |form|
      form.Field(:type_id).radios(
        post_types,
        class: "flex justify-center gap-0.5 flex-wrap",
      ) do |choice|
        choice.label(class: "world-post-type-choice-badge") do
          Components::Field(
            orientation: :horizontal,
            invalid: form.invalid?(:type_id),
            class: "badge font-normal",
            data: {
              variant: "ghost",
            },
          ) do
            Icon(choice.item.icon, data: { icon: "inline-start" })
            span do
              choice.item.label
            end
            button_link_to([ :edit, choice.item ], size: :icon_xs, data: {
              controller: "event",
              action: "event#stopPropagation",
            }) do
              Icon("huge/settings-01")
            end
            choice.input(
              name: "type_id",
              checked: choice.item == @selected_post_type,
              class: "visually-hidden",
              toggleable: true,
              data: {
                controller: "world-post-type-input",
                action: "world-post-type-input#updateSearchParams submit#request",
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
end
