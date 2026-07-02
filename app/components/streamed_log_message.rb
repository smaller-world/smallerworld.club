# typed: strict
# frozen_string_literal: true

# Components::StreamedLogMessage is a log message that is broadcasted to the
# client console as a Turbo Stream action.
class Components::StreamedLogMessage < Components::Base
  # == Initialization ==

  sig do
    params(
      message: String,
      controller_name: String,
      action_name: String,
      log_level: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(
    message:,
    controller_name:,
    action_name:,
    log_level: nil,
    **attributes
  )
    @message = message
    @controller_name = controller_name
    @action_name = action_name
    @log_level = log_level
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    template(
      data: {
        turbo_temporary: true,
        controller: "streamed-log-message",
        streamed_log_message_log_level_value: @log_level,
        streamed_log_message_controller_name_value: @controller_name,
        streamed_log_message_action_name_value: @action_name,
      },
    ) do
      @message
    end
  end
end
