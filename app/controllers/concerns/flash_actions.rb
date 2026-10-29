# typed: strict
# frozen_string_literal: true

module FlashActions
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ActionController::Base }

  private

  # == Methods ==

  sig { params(message: String, type: Symbol).returns(ActiveSupport::SafeBuffer) }
  def set_flash(message, type:)
    turbo_stream.update("flashes", renderable: Components::AppFlashAlert.new(type:, message:))
  end

  sig { params(message: String).returns(ActiveSupport::SafeBuffer) }
  def set_notice(message) # rubocop:disable Naming/AccessorMethodName
    set_flash(message, type: :notice)
  end

  sig { params(message: String).returns(ActiveSupport::SafeBuffer) }
  def set_alert(message) # rubocop:disable Naming/AccessorMethodName
    set_flash(message, type: :alert)
  end
end
