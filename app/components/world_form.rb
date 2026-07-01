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
    form_with(model: @world, **normalize_mix(
      {
        class: "flex flex-col gap-4",
        data: {
          controller: "create-world-button-label haptic-bridge",
          action: "turbo:submit-end->haptic-bridge#vibrate",
        },
      },
      @attributes,
    )) do |form|
      field_for(form, :name) do |f|
        f.label { "name" }
        f.text_input(
          required: true,
          placeholder: @world_owner.default_world_name,
          maxlength: World::NAME_MAX_LENGTH,
          data: {
            create_world_button_label_target: "nameInput",
            action: ("create-world-button-label#update" if @world.new_record?),
          },
        )
        f.error
      end

      div(
        class: "flex flex-col gap-2",
        data: { controller: "transition-group" },
      ) do
        if @world.blurb.blank?
          Components::Button(
            variant: :ghost,
            class: "text-muted-foreground",
            data: {
              transition_group_target: "item",
              controller: "transition",
              action: "transition#leave transition:transitioned->transition-group#startNext",
              transition_leave: "transition-opacity ease-out",
              transition_leave_end: "opacity-0",
            },
          ) do
            "add a tagline"
          end
        end

        field_for(
          form,
          :blurb,
          class: class_names("hidden" => @world.blurb.blank?),
          data: {
            transition_group_target: "item",
            controller: "transition",
            action: "transition-group:start->transition#enter",
            transition_enter: "transition-opacity ease-in",
            transition_enter_start: "opacity-0",
          },
        ) do |f|
          f.label { "tagline (optional)" }
          f.text_input
          f.description { "appears just below the world name" }
          f.error
        end
      end

      field_for(form, :icon, data: { controller: "field-error" }) do |f|
        f.label { "icon" }
        div(class: "flex flex-col items-center") do
          f.uppy_dnd(
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
            dropzone_class: "size-40 rounded-world-icon",
            data: {
              action: "uppy:error->field-error#show",
            },
          )
        end
        f.error(data: { field_error_target: "error" })
      end

      # if @world.persisted?
      #   Components::Card(class: "mt-4", size: hotwire_native_app? ? :sm : :default) do |card|
      #     card.content do
      #       key_label_fields(form:)
      #     end
      #   end
      # end

      submit_button_for(form, size: :lg) do |button|
        if @world.new_record?
          button.inline_start_icon("huge/plus-sign-square")
          span(data: { create_world_button_label_sync_target: "label" }) do
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
