# typed: strict
# frozen_string_literal: true

class Components::WorldKeyForm < Components::Base
  # == Initialization ==

  sig { params(world_key: WorldKey, attributes: T.untyped).void }
  def initialize(world_key:, **attributes)
    super(**attributes)
    @world_key = world_key
    @world = T.let(@world_key.world!, World)
    @recipient = T.let(@world_key.recipient!, User)
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
        field_set.legend(class: "text-center") do
          "which post types can #{@recipient.name} see?"
        end
        form.hidden_field(:granted_post_type_ids, multiple: true, value: nil)
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

      submit_button_for(form) do |button|
        button.inline_start_icon("huge/floppy-disk")
        span { "save changes" }
      end
    end
  end

  private

  # == Helpers ==

  sig { params(post_type: PostType, checkbox_group: Components::CheckboxGroup).void }
  def granted_post_type_choice_card_for(post_type, checkbox_group:)
    checkbox_group.field_label_for(post_type.id, class: "cursor-pointer w-fit") do |field_label|
      field_label.field(
        orientation: :horizontal,
        class: "w-auto py-1 pl-2 pr-2 items-center",
      ) do |field|
        field.content do
          field.title(class: "flex items-center gap-1.5") do
            Icon(post_type.icon, class: "size-4")
            span do
              post_type.label
            end
          end
        end
        field.checkbox_group_item_for(
          post_type.id,
          multiple: true,
          class: "rounded-full ",
        )
      end
    end
  end
end
