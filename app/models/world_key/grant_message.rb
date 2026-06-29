# typed: strict
# frozen_string_literal: true

class WorldKey::GrantMessage
  extend T::Sig
  include SmartProperties

  # == Properties ==

  property! :world_id, accepts: String
  property! :post_type_ids, accepts: Array

  sig { returns(PostType::PrivateRelation) }
  def post_types
    PostType.where(id: post_type_ids)
  end
end
