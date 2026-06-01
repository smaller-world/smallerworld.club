# typed: true
# frozen_string_literal: true

class DevicesController < ApplicationController
  def create
    # respond_to do |format|
    #   format.turbo_stream do
    #     current_user = current_user!
    #     device_params = params.expect(device: :token)
    #     device = current_user.devices.find_or_initialize_by(
    #       installation_id:,
    #       **device_params,
    #     ) do |device|
    #       device.platform = parse_platform(request.user_agent)
    #       device.name = parse_device_name(request.user_agent)
    #     end
    #     if device.save
    #     else
    #     end
    #   end
    # end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def installation_id
    cookies[:installation_id] or raise "Missing installation ID"
  end

  sig { params(scope: Device::PrivateRelation).returns(Device) }
  def find_device(scope: Device.all)
    scope.find(params.fetch(:id))
  end

  sig { params(user_agent: String).returns(Symbol) }
  def parse_platform(user_agent)
    case user_agent
    when /Hotwire Native Android/
      :google
    when /Hotwire Native iOS/
      :apple
    else
      raise ArgumentError, "Missing Hotwire Native platform marker"
    end
  end

  sig { params(user_agent: String).returns(T.nilable(String)) }
  def parse_device_name(user_agent)
    detector = DeviceDetector.new(user_agent, request.headers.to_h)
    detector.device_name
  end
end
