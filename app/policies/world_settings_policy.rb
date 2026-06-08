# typed: true
# frozen_string_literal: true

class WorldSettingsPolicy < ApplicationPolicy
  # == Rules ==

  # Only key recipients can manage settings
  def manage?
    world = T.let(record, World)
    user = user!
    world.keys.accepted.exists?(recipient: user)
  end
end
