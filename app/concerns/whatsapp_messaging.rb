# typed: true
# frozen_string_literal: true

module WhatsappMessaging
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Kernel }

  extend ActiveSupport::Concern

  # == Helpers ==

  module Helpers
    extend T::Sig

    sig { returns(String) }
    def application_user_lid
      Rails.configuration.x.whatsapp_user_lid
    end
  end

  class_methods do
    include Helpers
  end

  include Helpers
end
