# typed: true
# frozen_string_literal: true

class DevicePolicy < ApplicationPolicy
  # == Rules ==

  # Device owner can manage device
  def manage?
    device = T.let(record, Device)
    user = user!
    user == device.owner!
  end
end
