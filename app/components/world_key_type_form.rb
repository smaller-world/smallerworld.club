# typed: strict
# frozen_string_literal: true

class Components::WorldKeyTypeForm < Components::Base
  # == Initialization ==

  sig do
    params(key_type: WorldKeyType, return_url: T.nilable(String)).void
  end
  def initialize(key_type:, return_url:)
    super()
    @key_type = key_type
    @return_url = return_url
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @key_type,
      action:,
      vibrate_on_submit: true,
    ) do |form|
      if (return_url = @return_url)
        input(type: "hidden", name: "return_to", value: return_url)
      end

      form.wrapped(
        form.field(:name).text(
          placeholder: @key_type.name.presence || "close friends",
          required: true,
        ),
        label: "what's this key type called?",
      )

      Components::FieldSet(class: "gap-2") do |field_set|
        field_set.legend(variant: :label, class: "mb-0") do
          "key color"
        end
        form.Field(:color).radios(WorldKeyType.color.values, class: "flex flex-row") do |choice|
          choice.label(
            class: "w-auto cursor-pointer has-data-checked:border-key-foreground",
            data: { key_color: choice.item },
          ) do
            Components::Field(orientation: :horizontal, class: "p-3") do |field|
              Icon("huge/key-02", class: "size-6 text-key-foreground")
              choice.input(class: "visually-hidden")
            end
          end
        end
        form.error_for(:color)
      end

      form.submit do |button|
        if @key_type.new_record?
          button.inline_start_icon("huge/plus-sign-square")
          span { "create key type" }
        else
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Object) }
  def action
    if @key_type.new_record?
      [ @key_type.world!, :key_types ]
    else
      @key_type
    end
  end
end
