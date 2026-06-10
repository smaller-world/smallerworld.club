# typed: true
# frozen_string_literal: true

class WorldKeyPolicy < ApplicationPolicy
  # == Rules ==

  # World owner can manage keys
  def manage?
    key = T.let(record, WorldKey)
    user = user!
    key.world_owner! == user
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
      relation.where(recipient: user).or(WorldKey.where(world: user.owned_worlds))
    else
      relation.none
    end
  end
end
