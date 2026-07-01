# typed: true
# frozen_string_literal: true

class Components::WorldPostTypeForm < Components::Base
  # == Initialization ==

  sig { params(world: World, post_type: T.nilable(PostType), attributes: T.untyped).void }
  def initialize(world:, post_type:, **attributes)
    super(**attributes)
    @world = world
    @post_type = post_type
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      url: [ @world, :posts ],
      method: :get,
      data: {
        turbo_frame: "posts",
        controller: "submit",
      },
    ) do |form|
      Components::FieldSet() do |field_set|
        field_set.radio_group_for(
          form,
          :type_id,
          toggleable: true,
          class: "flex justify-center gap-0.5 flex-wrap",
        ) do |radio_group|
          authorized_scope(@world.post_types).chronological.each do |post_type|
            choice_badge_for(post_type, radio_group:)
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(post_type: PostType, radio_group: Components::RadioGroup).void }
  def choice_badge_for(post_type, radio_group:)
    radio_group.field_label_for(
      post_type.id,
      class: "world-post-type-choice-badge",
    ) do |field_label|
      field_label.field(
        orientation: :horizontal,
        class: "badge",
        data: {
          variant: "ghost",
        },
      ) do |field|
        Icon(post_type.icon, data: { icon: "inline-start" })
        span(class: "font-normal") do
          post_type.label
        end
        button_link_to([ :edit, post_type ], size: :icon_xs, data: {
          controller: "event",
          action: "event#stopPropagation",
        }) do
          Icon("huge/settings-01")
        end
        field.radio_group_item_for(
          post_type.id,
          checked: post_type == @post_type,
          class: "visually-hidden",
          input: {
            data: {
              controller: "world-post-type-input",
              action: "world-post-type-input#updateSearchParams submit#request",
            },
          },
        )
      end
    end
  end
end
