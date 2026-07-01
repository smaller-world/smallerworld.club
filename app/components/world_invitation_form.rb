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

      Components::FieldSet(class: "gap-0") do |field_set|
        field_set.legend(class: "text-center") do
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

      submit_button_for(form, size: :lg, class: "self-center") do |button|
        button.inline_start_icon("huge/mail-send-01")
        span { "send invite" }
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
          class: "rounded-full",
          input: {
            data: {
              action: "change->submit#request",
            },
          },
        )
      end
    end
  end
end
