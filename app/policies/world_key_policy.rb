# typed: true
# frozen_string_literal: true

class WorldKeyPolicy < ApplicationPolicy
  # == Rules ==

  # World owner can manage keys
  def manage?
    world_key = T.let(record, WorldKey)
    user = user!
    world_key.world_owner! == user
  end

  # # Key recipient can also destroy keys
  # def destroy?
  #   key = T.let(record, WorldKey)
  #   user = user!
  #   user.in?([ key.world_owner!, key.recipient! ])
  # end
  #
  # == Scopes ==

  scope_for :active_record_relation do |relation|
    relation = T.let(relation, WorldKey::PrivateRelation)
    if (user = self.user)
      relation.where(recipient: user).or(relation.where(world: user.owned_worlds))
    else
      relation.none
    end
  end
end
