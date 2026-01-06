# typed: true
# frozen_string_literal: true

class NativeDevicesController < ApplicationController
  # == Filters ==

  before_action :authenticate_user!

  # == Actions ==

  # POST /native_devices
  def create
    respond_to do |format|
      format.turbo_stream do
        current_user = authenticate_user!
        device_params = params.expect(native_device: :token)
        @native_device = current_user.native_devices.find_or_create_by(
          installation_id: cookies.fetch(:installation_id),
          **device_params,
        ) do |device|
          device.platform = parse_platform(request.user_agent)
          device.name = parse_device_name(request.user_agent)
        end
        unless @native_device.persisted?
          flash.now[:alert] = @native_device.errors.full_messages.first!
        end
      end
    end
  end

  # POST /native_devices/:id/test
  def test
    respond_to do |format|
      format.turbo_stream do
        native_device = find_native_device
        authorize!(native_device)
        native_device.send_test_notification
        head :no_content
      end
    end
  end

  private

  # == Helpers ==

  sig { params(scope: NativeDevice::PrivateRelation).returns(NativeDevice) }
  def find_native_device(scope: NativeDevice.all)
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
