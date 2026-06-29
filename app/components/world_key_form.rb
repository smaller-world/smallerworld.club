# typed: strict
# frozen_string_literal: true

class Components::WorldKeyForm < Components::Base
  # == Initialization ==

  sig { params(world_key: WorldKey, attributes: T.untyped).void }
  def initialize(world_key:, **attributes)
    super(**attributes)
    @world_key = world_key
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(model: @world_key, **mix(
      {
        class: "flex flex-col gap-6",
        data: {
          controller: "haptic-bridge",
          action: "turbo:submit-end->haptic-bridge#vibrate",
        },
      },
      @attributes,
    )) do |form|
      Components::FieldSet(class: "gap-0") do |field_set|
        form.hidden_field(:granted_post_type_ids, value: nil, multiple: true)
        field_set.legend(class: "text-center") do
          "which post types can #{world_key_recipient.name} see?"
        end
        checkbox_group_for(
          form,
          :granted_post_type_ids,
          class: "flex-row justify-center gap-2 flex-wrap",
        ) do |checkbox_group|
          @world_key.world_post_types.each do |post_type|
            granted_post_type_choice_card_for(post_type, checkbox_group:)
          end
        end
      end

      div(class: "flex flex-col gap-1 items-center") do
        submit_button_for(form) do |button|
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(User) }
  def world_key_recipient
    @world_key.recipient!
  end

  sig { params(post_type: PostType, checkbox_group: Components::CheckboxGroup).void }
  def granted_post_type_choice_card_for(post_type, checkbox_group:)
    checkbox_group.field_label_for(
      post_type.id,
      **compact_mix(
        {
          class: class_names(
            "cursor-pointer w-fit",
            "border-none bg-transparent" => !post_type.secret?,
          ),
        },
        nonsecret_post_type_label_attributes(post_type),
      ),
    ) do |field_label|
      field_label.field(
        orientation: :horizontal,
        class: class_names(
          "w-auto py-1 items-center",
          post_type.icon? ? "pl-2" : "pl-3",
          post_type.secret? ? "pr-2" : "pr-3",
        ),
        data: {
          disabled: ("true" unless post_type.secret?),
        },
      ) do |field|
        field.content do
          field.title(class: "flex items-center gap-1.5") do
            if (icon = post_type.icon)
              Icon(icon, class: "size-4")
            end
            span do
              post_type.label
            end
          end
        end
        field.checkbox_group_item_for(
          post_type.id,
          multiple: true,
          **compact_mix(
            { class: "rounded-full " },
            nonsecret_post_type_checkbox_attributes(post_type),
          ),
        )
      end
    end
  end

  sig { params(post_type: PostType).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def nonsecret_post_type_label_attributes(post_type)
    unless post_type.secret?
      {
        data: {
          disabled: "true",
          controller: "tippy",
          tippy_content_value:
            "only secret post types can be selectively shown to friends!",
          tippy_max_width_value: "calc(60 * var(--spacing))",
        },
      }
    end
  end

  sig { params(post_type: PostType).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def nonsecret_post_type_checkbox_attributes(post_type)
    unless post_type.secret?
      {
        disabled: true,
        checked: true,
        input: {
          name: nil,
        },
      }
    end
  end
end
