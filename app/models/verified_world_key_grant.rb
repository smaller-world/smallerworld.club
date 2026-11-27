# typed: strict
# frozen_string_literal: true

class VerifiedWorldKeyGrant
  extend T::Sig
  include SmartProperties

  # == Properties ==

  property! :key_type, accepts: WorldKeyType

  # == Methods ==

  sig { returns(World) }
  def world!
    key_type.world!
  end

  sig { params(attributes: T.untyped).returns(WorldInvitation) }
  def build_invitation(**attributes)
    world!.invitations.build(**attributes)
  end

  sig { returns(String) }
  def grant_message
    WorldKey.grant_message(key_type_id: key_type.id)
  end
end
