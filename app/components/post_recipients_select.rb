# typed: strict
# frozen_string_literal: true

class Components::PostRecipientsSelect < Components::Input
  include DeleteFrom

  # == Initialization ==

  sig do
    params(
      post: Post,
      value: T::Array[String],
      input_id_prefix: T.nilable(String),
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    post:,
    value: post.recipient_ids,
    input_id_prefix: nil,
    invalid: false,
    **attributes
  )
    super(invalid:, **attributes)
    @post = post
    @post_type = T.let(post.type!, PostType)
    @input_id_prefix = input_id_prefix
    @value = value
  end

  # == Component ==

  sig { override.void }
  def view_template
    attributes = @attributes
    input_attributes = delete_from(attributes, :name)

    div(class: "contents", data: { controller: "post-recipients-select" }) do
      Components::Popover() do |popover|
        popover.with_trigger_button(
          variant: :outline,
          size: :icon,
          **mix({ class: "post-recipients-select-trigger" }, attributes),
        ) do
          Icon("huge/user-group", class: "size-5")
          Components::Badge(data: { post_recipients_select_target: "badge" }) do
            @value.count
          end
        end
        popover.with_content(
          anchor: [ :bottom, :end ],
          class: "post-recipients-select-content",
        ) do |popover_content|
          popover_content.header do |popover_header|
            popover_header.title { "who can see this #{@post_type.label}" }
          end
          Components::CheckboxGroup() do
            if input_attributes[:name].present?
              input(type: "hidden", **input_attributes)
            end
            @post.type_recipients.each_with_index do |recipient, index|
              input_id = self.input_id(index:)
              Components::FieldLabel(for: input_id) do
                Components::Field(invalid: @invalid, orientation: :horizontal) do |field|
                  field.content do
                    field.title do
                      recipient.name
                    end
                  end
                  Components::Checkbox(
                    id: input_id,
                    value: recipient.id,
                    checked: @value.include?(recipient.id),
                    invalid: @invalid,
                    **mix(
                      {
                        data: {
                          post_recipients_select_target: "input",
                          action: "post-recipients-select#updateBadgeCount",
                        },
                      },
                      input_attributes,
                    ),
                  )
                end
              end
            end
          end
          Components::Empty(class: "hidden [.field-group:empty+&]:revert-display-layer") do |empty|
            empty.header do
              empty.media(variant: :icon) do
                Icon("huge/view-off")
              end
              empty.title(class: "flex flex-col gap-2") do
                span { "nobody in your world can see this type" }
              end
            end
            empty.content do
              button_link_to(
                "edit #{@post_type.label} type",
                [ :edit, @post_type ],
                variant: :default,
                icon: @post_type.icon,
                data: {
                  turbo_frame: "_top",
                  controller: "redirect-back-to-self",
                  action: "redirect-back-to-self#visit",
                },
              )
            end
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def input_id_prefix
    @input_id_prefix ||= dom_id(@post.id, :recipients_select)
  end

  sig { params(index: Integer).returns(String) }
  def input_id(index:)
    "#{input_id_prefix}_#{index}"
  end
end
