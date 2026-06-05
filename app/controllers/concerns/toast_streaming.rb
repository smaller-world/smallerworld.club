# typed: strict
# frozen_string_literal: true

module ToastStreaming
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ApplicationController }

  private

  # == Methods ==

  sig do
    params(message: String, type: T.nilable(Symbol))
      .returns(ActiveSupport::SafeBuffer)
  end
  def append_toast(message, type: nil)
    turbo_stream.append(
      "toasts",
      renderable: Components::StreamedToast.new(message:, type:),
    )
  end
end
