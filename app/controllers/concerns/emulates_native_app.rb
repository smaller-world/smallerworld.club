# typed: true
# frozen_string_literal: true

module EmulatesNativeApp
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  # == Annotations ==

  requires_ancestor { ApplicationController }

  # == Patches ==

  module EmulateTurboNativeNavigation
    extend T::Sig
    extend T::Helpers
    extend ActiveSupport::Concern

    requires_ancestor { ApplicationController }

    # == Methods ==

    sig { returns(T::Boolean) }
    def hotwire_native_app?
      super || emulating_hotwire_native_app?
    end

    private

    sig { returns(T::Boolean) }
    def emulating_hotwire_native_app?
      params[:emulate_native_app].truthy?
    end
  end

  # == Hooks ==

  included do
    prepend EmulateTurboNativeNavigation
  end
end
