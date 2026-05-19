# typed: true
# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  extend T::Sig

  # Configure additional authorization contexts here
  # (`user` is added by default).
  #
  #   authorize :account, optional: true
  #
  # Read more about authorization context: https://actionpolicy.evilmartians.io/#/authorization_context

  # == Rules ==

  private

  # Define shared methods useful for most policies.
  # For example:
  #
  #  def owner?
  #    record.user_id == user.id
  #  end

  sig { returns(User) }
  def user!
    user or deny!
  end
end
