# typed: strict
# frozen_string_literal: true

# Components::StreamedToast is a toast that is broadcasted to the client as a
# Turbo Stream action.
class Components::StreamedToast < Components::Base
  # == Configuration ==

  TYPES = [ :success, :error, :warning, :info ]

  # == Initialization ==

  sig do
    params(
      message: String,
      type: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(
    message:,
    type: nil,
    **attributes
  )
    unless type.in?(TYPES)
      raise InvalidParameter.new(parameter: :type, value: type)
    end

    @message = message
    @type = type
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    template(
      data: {
        controller: "streamed-toast",
        streamed_toast_type_value: @type,
      },
    ) do
      @message
    end
  end
end
