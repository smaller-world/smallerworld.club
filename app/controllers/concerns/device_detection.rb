# typed: strict
# frozen_string_literal: true

module DeviceDetection
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ActionController::Base }

  included do
    extend T::Sig

    T.bind(self, T.class_of(ActionController::Base))

    helper_method :ios_browser?
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
    if (param = params[:emulate_ios_browser])
      ActiveModel::Type::Boolean.new.cast(param)
    else
      false
    end
  end

  sig { returns(T.nilable(String)) }
  def device_name
    client.device_name
  end
end
