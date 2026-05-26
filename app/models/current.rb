# typed: strict
# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  extend T::Sig

  # == Attributes ==

  attribute :session
  delegate :user, to: :session, allow_nil: true
end
