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

  # == Helpers ==

  sig { returns(Symbol) }
  def parse_device_platform
    case request.user_agent
    when /Hotwire Native Android/
      :google
    when /Hotwire Native iOS/
      :apple
    else
      raise ArgumentError, "Missing Hotwire Native platform marker"
    end
  end

  # == Callbacks ==

  sig { void }
  def set_device
    if (identifier = cookies[:device_identifier])
      device = Device.find_or_initialize_by(identifier:) do |device|
        device.platform = parse_device_platform
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
