# typed: strict
# frozen_string_literal: true

class Components::WorldInvitationForm < Components::Base
  # == Initialization ==

  sig do
    params(
      invitation: WorldInvitation,
      previous_url: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def initialize(invitation:, previous_url: nil, **attributes)
    super(**attributes)
    @invitation = invitation
    @previous_url = previous_url
    @world = T.let(@invitation.world!, World)
    @recipient = T.let(@invitation.recipient!, User)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @invitation,
      vibrate_on_submit: true,
      **mix(
        {
          data: {
            controller: "submit",
          },
        },
        @attributes,
      ),
    ) do |form|
      if (previous_url = @previous_url)
        input(type: "hidden", name: "previous_url", value: previous_url)
      end
      if @invitation.new_record?
        form.Field(:recipient_id).hidden
      end

      Components::FieldSet() do |field_set|
        field_set.legend(class: "text-center mb-0") do
          "invite #{@recipient.name} to see:"
        end
        form.Field(:granted_post_type_ids).checkboxes(
          @world.post_types,
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
        field_set.description(
          class: class_names(
            "mt-0 text-center [[data-slot=checkbox-group]:has(:checked)+&]:hidden",
            "hidden" => form.invalid?(:granted_post_type_ids),
          ),
        ) do
          "select at least one"
        end
        form.error_for(:granted_post_type_ids, class: "text-center")
      end

      form.submit(size: :lg) do |button|
        if @invitation.new_record?
          button.inline_start_icon("huge/mail-send-01")
          span { "send invite" }
        else
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end
end
