# typed: true
# frozen_string_literal: true

class WorldInvitationPolicy < ApplicationPolicy
  # == Rules ==

  def show?
    invitation = T.let(record, WorldInvitation)
    user = user!
    if (recipient = invitation.recipient)
      recipient == user
    else
      invitation.recipient_phone_number == user.phone_number
    end
  end

  def manage?
    invitation = T.let(record, WorldInvitation)
    user = user!
    invitation.world_owner! == user
  end
end
