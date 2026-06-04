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
      **mix({ class: "overflow-x-auto" }, @attributes),
    ) do |alert|
      Icon(@type == :alert ? "huge/alert-01" : "huge/information-circle")
      alert.description do
        @message
      end
    end
  end
end
