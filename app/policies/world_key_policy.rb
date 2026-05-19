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
end
