# typed: true
# frozen_string_literal: true

module NativeDevicesHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  # == Methods ==

  sig { returns(T::Boolean) }
  def installation_id?
    cookies.include?(:installation_id)
  end
end
