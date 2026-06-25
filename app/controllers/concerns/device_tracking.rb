# typed: strict
# frozen_string_literal: true

module DeviceTracking
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern
  include DeviceDetection

  requires_ancestor { ActionController::Base }

  included do
    T.bind(self, T.class_of(ActionController::Base))

    # == Filters ==

    before_action :set_device
  end

  private

  # == Callbacks ==

  sig { void }
  def set_device
    if (identifier = cookies[:device_identifier])
      device = Device.find_or_initialize_by(identifier:) do |device|
        device.platform = hotwire_native_platform
        device.name = device_name
      end
      if (user = Current.user)
        device.owner = user
      end
      device.save!
      Current.device = device
    end
  end
end
