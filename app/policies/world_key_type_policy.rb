# typed: true
# frozen_string_literal: true

class WorldKeyTypePolicy < ApplicationPolicy
  # == Rules ==

  def manage?
    key_type = T.let(record, WorldKeyType)
    user = user!
    user.owned_worlds.include?(key_type.world!)
  end

  # == Scopes ==

  scope_for :active_record_relation do |relation|
    relation = T.let(relation, WorldKeyType::PrivateRelation)
    if (user = self.user)
      relation.where(world_id: user.owned_worlds.select(:id))
    else
      relation.none
    end
  end
end
