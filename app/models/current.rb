# typed: strict
# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  extend T::Sig

  # == Attributes ==

  attribute :session
  delegate :user, to: :session, allow_nil: true

  attribute :device

  # == Helpers ==

  sig { returns(User) }
  def self.user!
    user or raise ApplicationError, "Missing current user"
  end

  sig { returns(Device) }
  def self.device!
    device or raise ApplicationError, "Missing current device"
  end
end
