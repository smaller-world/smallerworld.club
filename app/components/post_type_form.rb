# typed: strict
# frozen_string_literal: true

class Components::PostTypeForm < Components::Base
  # == Initialization ==

  sig { params(post_type: PostType, attributes: T.untyped).void }
  def initialize(post_type:, **attributes)
    super(**attributes)
    @post_type = post_type
    @world = T.let(@post_type.world!, World)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(model:, **mix(
      {
        class: "flex flex-col gap-6",
        data: {
          controller: "submit haptic-bridge",
          action: "turbo:submit-end->haptic-bridge#vibrate",
        },
      },
      @attributes,
    )) do |form|
      field_for(form, :label) do |f|
        f.label { "what's this post type called?" }
        f.input(
          placeholder: @post_type.label.presence || "journal entry",
          required: true,
          data: {
            action: "keydown->submit#preventSubmitOnEnter",
          },
        )
        f.error
      end

      world_keys = @post_type.world_keys.includes(:recipient)
      Components::FieldSet(
        class: class_names("gap-1", "hidden" => world_keys.none?),
      ) do |field_set|
        field_set.legend(class: "mb-0") do
          "who can see this post type?"
        end
        checkbox_group_for(
          form,
          :granted_world_key_ids,
          class: "flex-row gap-1.5 flex-wrap",
        ) do |checkbox_group|
          world_keys.find_each do |world_key|
            granted_world_key_choice_card_for(world_key, checkbox_group:)
          end
        end
      end

      # Components::FieldSet(class: "gap-1") do |field_set|
      #   field_set.legend(class: "mb-0") do
      #     "are these posts loud or quiet?"
      #   end
      #   field_set.description do
      #     "you can change this setting on a per-post basis"
      #   end
      #   radio_group_for(form, :quiet, class: "mt-2") do |radio_group|
      #     choice_card_for(:off, radio_group:) do |field|
      #       Icon("huge/notification-01", class: "size-4 mt-0.5")
      #       div(class: "flex-1 flex flex-col gap-0.5") do
      #         field.title do
      #           "loud by default"
      #         end
      #         field.description do
      #           "loud posts appear in your world and generate a notification when posted"
      #         end
      #       end
      #     end
      #     choice_card_for(:on, radio_group:, class: "border-dashed") do |field|
      #       Icon("huge/notification-snooze-01", class: "size-4 mt-0.5")
      #       div(class: "flex-1 flex flex-col gap-0.5") do
      #         field.title do
      #           "quiet by default"
      #         end
      #         field.description do
      #           "quiet posts are hidden in their own section, and " \
      #             "do not generate a notification when posted"
      #         end
      #       end
      #     end
      #   end
      # end

      div(class: "flex flex-col gap-1") do
        submit_button_for(form) do |button|
          if @post_type.new_record?
            button.inline_start_icon("huge/plus-sign-square")
            span { "create post type" }
          else
            button.inline_start_icon("huge/floppy-disk")
            span { "save changes" }
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Object) }
  def model
    if @post_type.new_record?
      [ @world, @post_type ]
    else
      @post_type
    end
  end

  sig { params(world_key: WorldKey, checkbox_group: Components::CheckboxGroup).void }
  def granted_world_key_choice_card_for(world_key, checkbox_group:)
    recipient = world_key.recipient!
    checkbox_group.field_label_for(
      world_key.id,
      class: "cursor-pointer w-fit",
    ) do |field_label|
      field_label.field(
        orientation: :horizontal,
        class: "w-auto py-1 pl-3 pr-2 items-center",
      ) do |field|
        field.content do
          field.title(class: "flex items-center gap-1.5") do
            recipient.name
          end
        end
        field.checkbox_group_item_for(
          world_key.id,
          multiple: true,
          class: "rounded-full",
        )
      end
    end
  end
end
