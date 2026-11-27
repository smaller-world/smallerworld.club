# typed: strict
# frozen_string_literal: true

class Components::Todo < Components::Base
  sig { params(message: String).void }
  def initialize(message:)
    super()
    @message = message
  end

  sig { override.void }
  def view_template
    Components::Empty() do |empty|
      empty.header(class: "flex-row items-center") do
        empty.media(variant: :icon, class: "mb-0") do
          Icon("huge/wrench-01")
        end
        div(class: "flex items-center gap-1.5") do
          empty.title { "TODO:" }
          empty.description { @message }
        end
      end
    end
  end
end
