# typed: strict
# frozen_string_literal: true

module LogStreaming
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ActionController::Base }

  private

  # == Methods ==

  sig do
    params(message: String, level: T.nilable(Symbol))
      .returns(ActiveSupport::SafeBuffer)
  end
  def append_log_message(message, level: nil)
    turbo_stream.append(
      "logs",
      renderable: Components::StreamedLogMessage.new(
        message:,
        controller_name:,
        action_name:,
        level:,
      ),
    )
  end
end
