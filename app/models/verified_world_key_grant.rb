# typed: strict
# frozen_string_literal: true

class VerifiedWorldKeyGrant
  extend T::Sig
  include SmartProperties

  # == Properties ==

  property! :world_id, accepts: String
  property! :post_type_ids, accepts: Array

  # == Methods ==

  sig { returns(World) }
  def world
    World.find(world_id)
  end

  sig { returns(PostType::PrivateRelation) }
  def post_types
    PostType.where(id: post_type_ids)
  end

  sig { returns(String) }
  def grant_message
    world.key_grant_message(post_type_ids:)
  end
end
