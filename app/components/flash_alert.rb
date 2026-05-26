# typed: strict
# frozen_string_literal: true

class Components::FlashAlert < Components::Base
  # == Initialization ==

  sig { params(message: String, type: Symbol, attributes: T.untyped).void }
  def initialize(message:, type: :notice, **attributes)
    @message = message
    @type = type
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Alert(variant: @type == :alert ? :destructive : :default) do |alert|
      Icon(@type == :alert ? "huge/alert-01" : "huge/information-circle")
      alert.description do
        @message
      end
    end
  end
end
