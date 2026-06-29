# typed: true
# frozen_string_literal: true

class WorldPolicy < ApplicationPolicy
  # == Rules ==

  # World can be accessed if user owns it or has a world key.
  def show?
    world = T.let(record, World)
    user = user!
    user == world.owner! || world.keys.exists?(recipient: user)
  end

  # World owner can manage world
  def manage?
    world = T.let(record, World)
    user = user!
    user == world.owner!
  end

  # Only key recipients can manage settings
  def leave?
    world = T.let(record, World)
    user = user!
    world.keys.exists?(recipient: user)
  end
end
