# typed: true
# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  # == Attributes ==

  attribute :session, :native_device
  delegate :user, to: :session, allow_nil: true
end
