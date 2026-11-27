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
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @invitation,
      vibrate_on_submit: true,
      **@attributes,
    ) do |form|
      if (previous_url = @previous_url)
        input(type: "hidden", name: "previous_url", value: previous_url)
      end
      if @invitation.new_record?
        form.Field(:recipient_id).hidden
      end

      # TODO: Add key_type_id selection and submission for new and existing invitations.
      Components::Todo(message: "implement invitation key type selection")
    end
  end
end
