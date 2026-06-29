# typed: strict
# frozen_string_literal: true

class Components::WorldInvitationForm < Components::Base
  # == Initialization ==

  sig do
    params(
      invitation: WorldInvitation,
      attributes: T.untyped,
    ).void
  end
  def initialize(invitation:, **attributes)
    super(**attributes)
    @invitation = invitation
  end

  # == Component ==

  sig { override.void }
  def view_template
    recipient = @invitation.recipient!

    form_with(model: @invitation, **normalize_mix(
      {
        class: "flex flex-col gap-6",
        data: {
          controller: "submit",
        },
      },
      @attributes,
    )) do |form|
      form.hidden_field(:recipient_id)

      Components::Card(size: :sm) do |card|
        card.content do
          Components::FieldSet(class: "gap-2") do |field_set|
            field_set.legend(class: "mb-0 text-center") do
              "invite #{recipient.name} to see:"
            end
            checkbox_group_for(
              form,
              :granted_post_type_ids,
              class: "flex-row justify-center gap-2 flex-wrap",
            ) do |checkbox_group|
              @invitation.world_post_types.each do |post_type|
                granted_post_type_choice_card_for(post_type, checkbox_group:)
              end
            end
          end
        end
      end

      submit_button_for(form, size: :lg) do |button|
        button.inline_start_icon("huge/mail-send-01")
        span { "send invite" }
      end
    end
  end

  private

  # == Helpers ==

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
            {
              class: "rounded-full",
              input: {
                data: {
                  action: "change->submit#request",
                },
              },
            },
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
