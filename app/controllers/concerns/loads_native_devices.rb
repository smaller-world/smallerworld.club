# typed: true
# frozen_string_literal: true

module LoadsNativeDevices
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern
  include RendersJsonException

  requires_ancestor { ApplicationController }

  included do
    T.bind(self, T.class_of(ApplicationController))

    # == Filters ==

    before_action :load_native_device

    # == Helpers ==

    helper_method :current_native_device
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(NativeDevice)) }
  def current_native_device
    Current.native_device
  end


  sig { returns(T.nilable(NativeDevice)) }
  def find_native_device_by_cookie
    if (installation_id = cookies[:installation_id])
      NativeDevice.find_by(installation_id:)
    end
  end


  # == Filter handlers ==

  sig { returns(T.nilable(NativeDevice)) }
  def load_native_device
    Current.native_device ||= find_native_device_by_cookie
  end
end
