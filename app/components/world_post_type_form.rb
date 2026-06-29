# typed: true
# frozen_string_literal: true

class Components::WorldPostTypeForm < Components::Base
  # == Initialization ==

  sig { params(world: World, attributes: T.untyped).void }
  def initialize(world:, **attributes)
    super(**attributes)
    @world = world
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
          class: "flex justify-center gap-1 flex-wrap",
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
      class: "world-post-type-field-label",
    ) do |field_label|
      field_label.field(
        orientation: :horizontal,
        class: "badge world-post-type-choice-badge",
        data: {
          variant: "ghost",
          # secret: post_type.secret,
        },
      ) do |field|
        if (icon = post_type.icon)
          Icon(icon, data: { icon: "inline-start" })
        end
        span(class: "font-normal") do
          post_type.label
        end
        field.radio_group_item_for(
          post_type.id,
          class: "visually-hidden",
          input: {
            data: {
              action: "submit#request",
            },
          },
        )
      end
    end
  end
end
