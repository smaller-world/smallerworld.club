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
      description: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def initialize(
    message:,
    type: nil,
    description: nil,
    **attributes
  )
    if type && !type.in?(TYPES)
      raise InvalidParameter.new(parameter: :type, value: type)
    end

    @message = message
    @type = type
    @description = description
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    template(**mix(
      {
        data: {
          turbo_temporary: true,
          controller: "streamed-toast",
          streamed_toast_type_value: @type,
        },
      },
      @attributes,
    )) do
      @message
    end
  end
end
