# typed: true
# frozen_string_literal: true

class NativeDevicePolicy < ApplicationPolicy
  # == Rules ==

  def manage?
    native_device = T.cast(record, NativeDevice)
    native_device.owner! == user!
  end
end
