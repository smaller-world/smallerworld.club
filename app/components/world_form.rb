# typed: strict
# frozen_string_literal: true

class Components::WorldForm < Components::Base
  # == Initialization ==

  sig { params(world: World, attributes: T.untyped).void }
  def initialize(world:, **attributes)
    super(**attributes)
    @world = world
    @world_owner = T.let(@world.owner!, User)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(@world, **mix(
      {
        data: {
          controller: "create-world-form haptic-bridge",
          action: "turbo:submit-end->haptic-bridge#vibrate",
        },
      },
      @attributes,
    )) do |form|
      form.wrapped(
        form.field(:name).text(
          required: true,
          placeholder: @world_owner.default_world_name,
          maxlength: World::NAME_MAX_LENGTH,
          data: {
            create_world_form_target: "nameInput",
            action: ("create-world-button-label#updateSubmitLabel" if @world.new_record?),
          },
        ),
      )

      div(class: "flex flex-col gap-2", data: { controller: "transition-group" }) do
        if @world.blurb.blank?
          Components::Button(
            type: :button,
            variant: :outline,
            class: "text-muted-foreground self-center",
            data: {
              transition_group_target: "item",
              controller: "transition",
              action: "transition#leave transition:transitioned->transition-group#startNext",
              transition_leave: "transition-opacity ease-out",
              transition_leave_end: "opacity-0",
            },
          ) do |button|
            button.inline_start_icon("huge/quotes")
            span { "add a tagline" }
          end
        end

        form.wrapped(
          form.field(:blurb).input do |input|
            Components::InputGroup() do |input_group|
              input_group.addon(align: :inline_start) do
                Icon("huge/quotes")
              end
              input_group.input(**input.attributes)
              input_group.addon(align: :inline_end, &:clear_button)
            end
          end,
          label: "tagline (optional)",
          description: "appears just below the world name",
          class: class_names("hidden" => @world.blurb.blank?),
          data: {
            transition_group_target: "item",
            controller: "transition",
            action: "transition-group:start->transition#enter",
            transition_enter: "transition-opacity ease-in",
            transition_enter_start: "opacity-0",
          },
        )
      end

      form.wrapped(
        form.field(:icon).uppy(
          required: true,
          allowed_file_types: [
            "image/png",
            "image/jpeg",
            "image/gif",
            "image/heic",
            "image/webp",
            # "image/svg+xml",
            "image/avif",
          ],
          crop_to_aspect_ratio: 1,
          dropzone_class: "size-40 rounded-world-icon mx-auto",
          data: {
            action: "uppy:error->field-error#show",
          },
        ),
        error: {
          data: {
            field_error_target: "error",
          },
        },
        data: {
          controller: "field-error",
        },
      )

      # if @world.persisted?
      #   Components::Card(class: "mt-4", size: hotwire_native_app? ? :sm : :default) do |card|
      #     card.content do
      #       key_label_fields(form:)
      #     end
      #   end
      # end

      form.submit(size: :lg) do |button|
        if @world.new_record?
          button.inline_start_icon("huge/plus-sign-square")
          span(data: { create_world_form_target: "submitLabel" }) do
            "create world"
          end
        else
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end

  # private

  # == Helpers ==

  # sig { params(form: PhlexRailsFormBuilder).void }
  # def key_label_fields(form:)
  #   Components::FieldSet() do |set|
  #     div do
  #       set.legend(class: "mb-0") do
  #         "key labels"
  #       end
  #       set.description do
  #         "help yourself remember what your key colors represent!"
  #       end
  #     end
  #     set.group(class: "md:grid md:grid-cols-2 gap-2") do
  #       WorldKey.color.values.each do |value|
  #         field_for(form, :"#{value}_key_label") do |field|
  #           field.input_group do |group|
  #             group.addon do
  #               Icon("huge/key-02", style: "color: var(--world-key-color-#{value})")
  #             end
  #             group.text_input(
  #               placeholder: value.humanize(capitalize: false),
  #               class: "text-end",
  #             )
  #             group.addon(align: :inline_end) do |addon|
  #               addon.text { "key" }
  #             end
  #           end
  #           field.error
  #         end
  #       end
  #     end
  #   end
  # end
end
