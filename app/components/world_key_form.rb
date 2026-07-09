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
    Components::Form(@world_key, vibrate_on_submit: true) do |form|
      Components::FieldSet() do |field_set|
        field_set.legend(class: "text-center mb-0") do
          "which post types can #{@recipient.name} see?"
        end
        form.Field(:granted_post_type_ids).checkboxes(
          @world_key.world_post_types,
          class: "flex-row justify-center gap-2 flex-wrap",
        ) do |choice|
          choice.label(class: "cursor-pointer w-fit") do
            Components::Field(
              orientation: :horizontal,
              invalid: form.invalid?(:granted_post_type_ids),
              class: "w-auto py-1 pl-2 pr-2 items-center",
            ) do |field|
              field.content do
                field.title(class: "flex items-center gap-1.5") do
                  Icon(choice.item.icon, class: "size-4")
                  span do
                    choice.item.label
                  end
                end
              end
              choice.input(class: "rounded-full")
            end
          end
        end
        form.error_for(:granted_post_type_ids)
      end

      form.submit do |button|
        button.inline_start_icon("huge/floppy-disk")
        span { "save changes" }
      end
    end
  end
end
