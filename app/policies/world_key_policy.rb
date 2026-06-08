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
end
