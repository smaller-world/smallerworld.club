# typed: strict
# frozen_string_literal: true

class Components::AppFlashAlert < Components::Base
  # == Initialization ==

  sig { params(message: String, type: Symbol, attributes: T.untyped).void }
  def initialize(message:, type: :notice, **attributes)
    super(**attributes)
    @message = message
    @type = type
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Alert(
      variant: @type == :alert ? :destructive : :default,
      **mix(
        {
          class: "overflow-x-auto starting:opacity-0 starting:scale-95",
          data: {
            turbo_temporary: true,
            controller: "transition",
            transition_leave: "transition-[scale,opacity] duration-200 ease-out-quart",
          },
        },
        @attributes,
      ),
    ) do |alert|
      Icon(@type == :alert ? "huge/alert-01" : "huge/information-circle")
      alert.title do
        @message
      end
      alert.action do
        Components::Button(variant: :ghost, size: :icon_xs, data: {
          action: "transition#leave",
        }) do
          Icon("huge/cancel-01")
        end
      end
    end
  end
end
