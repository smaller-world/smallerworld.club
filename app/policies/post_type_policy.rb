# typed: true
# frozen_string_literal: true

class PostTypePolicy < ApplicationPolicy
  # == Rules ==

  def manage?
    post_type = T.let(record, PostType)
    user = user!
    user.owned_worlds.include?(post_type.world!)
  end

  # == Scopes ==

  scope_for :active_record_relation do |relation|
    relation = T.let(relation, PostType::PrivateRelation)
    if (user = self.user)
      relation.where(world_id: user.owned_worlds.select(:id))
        .or(relation.where(
          id: PostTypeGrant
            .where(world_key: WorldKey.where(recipient: user))
            .select(:post_type_id),
        ))
    else
      relation.none
    end
  end
end
