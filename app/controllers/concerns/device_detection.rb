# typed: strict
# frozen_string_literal: true

module DeviceDetection
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern
  include BooleanParams

  requires_ancestor { ActionController::Base }

  # == Configuration ==

  HOTWIRE_NATIVE_PLATFORMS = T.let([ :ios, :ios_app_on_mac, :android ], T::Array[Symbol])

  included do
    extend T::Sig

    T.bind(self, T.class_of(ActionController::Base))

    # == Configuration ==

    helper_method :hotwire_native_platform,
      :hotwire_native_ios?,
      :hotwire_native_android?,
      :hotwire_native_ios_app_on_mac?
  end

  private

  # == Methods ==

  sig { returns(DeviceDetector) }
  def client
    @client ||= T.let(
      DeviceDetector.new(request.user_agent, request.headers.to_h),
      T.nilable(DeviceDetector),
    )
  end

  sig { returns(T::Boolean) }
  def ios_browser?
    client.os_family == "iOS" || emulate_ios_browser?
  end

  sig { returns(T::Boolean) }
  def emulate_ios_browser?
    cast_boolean(params[:emulate_ios_browser])
  end

  sig { returns(T.nilable(String)) }
  def device_name
    client.device_name
  end

  sig { returns(T.nilable(Symbol)) }
  def hotwire_native_platform
    user_agent = request.user_agent
    @hotwire_native_platform ||= T.let(
      case user_agent
      when /Hotwire Native Android/
        :android
      when /Hotwire Native iOS/
        if user_agent.include?("SmallerWorldIosAppOnMac")
          :ios_app_on_mac
        else
          :ios
        end
      end,
      T.nilable(Symbol),
    )
  end

  sig { returns(T::Boolean) }
  def hotwire_native_android?
    hotwire_native_platform == :android
  end

  sig { returns(T::Boolean) }
  def hotwire_native_ios?
    hotwire_native_platform == :ios
  end

  sig { returns(T::Boolean) }
  def hotwire_native_ios_app_on_mac?
    hotwire_native_platform == :ios_app_on_mac
  end
end
