# typed: strict
# frozen_string_literal: true

module DeviceTracking
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ApplicationController }

  extend ActiveSupport::Concern

  included do
    extend T::Sig

    T.bind(self, T.class_of(ApplicationController))

    before_action :set_device
  end

  private

  sig { void }
  def set_device
    if (identifier = cookies[:device_identifier])
      device = Device.find_or_initialize_by(identifier:) do |device|
        device.platform = parse_device_platform
        device.name = parse_device_name
      end
      if (user = Current.user)
        device.owner = user
      end
      device.save!
      Current.device = device
    end
  end

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

  sig { returns(T.nilable(String)) }
  def parse_device_name
    detector = DeviceDetector.new(request.user_agent, request.headers.to_h)
    detector.device_name
  end
end
