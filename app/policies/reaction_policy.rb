# typed: true
# frozen_string_literal: true

class ReactionPolicy < ApplicationPolicy
  # == Rules ==

  def manage?
    reaction = T.let(record, Reaction)
    user = user!
    reaction.reactor_id == user.id
  end
end
