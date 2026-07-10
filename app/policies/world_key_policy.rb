# typed: true
# frozen_string_literal: true

class WorldKeyPolicy < ApplicationPolicy
  # == Rules ==

  # Key recipient can view thier own key
  def show?
    world_key = T.let(record, WorldKey)
    user = user!
    world_key.recipient! == user
  end

  # World owner can manage keys
  def manage?
    world_key = T.let(record, WorldKey)
    user = user!
    world_key.world_owner! == user
  end

  # Owners and recipients can both destroy keys
  def destroy?
    world_key = T.let(record, WorldKey)
    user = user!
    user.in?([ world_key.world_owner!, world_key.recipient! ])
  end

  # Key recipients can track visits to the key's associated world
  alias_rule :track_world_visit?, to: :show?

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
