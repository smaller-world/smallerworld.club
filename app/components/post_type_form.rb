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
    Components::Form(
      @post_type,
      action: @post_type.new_record? ? [ @world, @post_type ] : @post_type,
      vibrate_on_submit: true,
    ) do |form|
      form.wrapped(
        form.field(:label).text(
          placeholder: @post_type.label.presence || "journal entry",
          required: true,
          data: {
            controller: "prevent-enter-submit",
          },
        ),
        label: "what's this post type called?",
      )

      world_keys = @post_type.world_keys.includes(:recipient)
      Components::FieldSet(
        class: class_names("gap-2", "hidden" => world_keys.none?),
      ) do |field_set|
        field_set.legend(class: "mb-0") do
          "who can see this post type?"
        end
        form.Field(:granted_world_key_ids).checkboxes(
          world_keys,
          class: "flex-row gap-1.5 flex-wrap",
        ) do |choice|
          recipient = choice.item.recipient!
          choice.label(class: "cursor-pointer w-fit") do
            Components::Field(
              orientation: :horizontal,
              invalid: form.invalid?(:granted_world_key_ids),
              class: "w-auto py-1 pl-2 pr-2 items-center",
            ) do |field|
              field.content do
                field.title(class: "flex items-center gap-1.5") do
                  recipient.name
                end
              end
              choice.input(class: "rounded-full")
            end
          end
        end
        form.error_for(:granted_world_key_ids)
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

      form.submit do |button|
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
