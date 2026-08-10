# typed: true
# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # == Rules ==

  def report?
    target_user = T.let(record, User)
    user = user!
    WorldKey.exists?(world: target_user.owned_worlds, recipient: user)
  end
end
