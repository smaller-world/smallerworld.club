# typed: strict
# frozen_string_literal: true

module ClientDetection
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern
  include BooleanParams

  requires_ancestor { ActionController::Base }

  # == Configuration ==

  included do
    extend T::Sig

    T.bind(self, T.class_of(ActionController::Base))

    # == Configuration ==

    helper_method :ios_browser?,
      :android_browser?,
      :hotwire_native_platform,
      :hotwire_native_ios?,
      :hotwire_native_android?,
      :native_client_name,
      :native_client_version,
      :native_client_identifier
  end

  # == Methods ==

  sig { returns(T::Boolean) }
  def ios_browser?
    client.os_family == "iOS" || emulate_ios_browser?
  end

  sig { returns(T::Boolean) }
  def android_browser?
    client.os_family == "Android" || emulate_android_browser?
  end

  sig { returns(T.nilable(String)) }
  def device_name
    client.device_name
  end

  sig { returns(T.nilable(String)) }
  def native_client_version
    native_client_info&.last
  end

  sig { returns(T.nilable(String)) }
  def native_client_name
    native_client_info&.first
  end

  sig { returns(T.nilable(String)) }
  def native_client_identifier
    native_client_info&.join(" ")
  end

  sig { returns(T.nilable(Symbol)) }
  def hotwire_native_platform
    user_agent = request.user_agent
    @hotwire_native_platform ||= T.let(
      case user_agent
      when /Hotwire Native Android/
        :android
      when /Hotwire Native iOS/
        :ios
      end,
      T.nilable(Symbol),
    )
  end

  sig { returns(T::Boolean) }
  def hotwire_native_ios?
    hotwire_native_platform == :ios
  end

  sig { returns(T::Boolean) }
  def hotwire_native_android?
    hotwire_native_platform == :android
  end

  private

  # == Helpers ==

  sig { returns(DeviceDetector) }
  def client
    @client ||= T.let(
      DeviceDetector.new(request.user_agent, request.headers.to_h),
      T.nilable(DeviceDetector),
    )
  end

  sig { returns(T::Boolean) }
  def emulate_ios_browser?
    cast_boolean(params[:emulate_ios_browser])
  end

  sig { returns(T::Boolean) }
  def emulate_android_browser?
    cast_boolean(params[:emulate_android_browser])
  end

  sig { returns(T.nilable([ String, T.nilable(String) ])) }
  def native_client_info
    return @native_client_info if defined?(@native_client_info)

    matches = %r{(?<name>SmallerWorldIos|SmallerWorldAndroid)(/(?<version>\d\.\d\.\d))?}
      .match(request.user_agent)
    @native_client_info = T.let(
      if matches && (name = matches.named_captures["name"])
        [ name, matches.named_captures["version"] ]
      end,
      T.nilable([ String, T.nilable(String) ]),
    )
  end
end
