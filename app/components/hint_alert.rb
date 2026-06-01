# typed: strict
# frozen_string_literal: true

class Components::HintAlert < Components::Base
  sig { params(message: String, attributes: T.untyped).void }
  def initialize(message:, **attributes)
    super(**attributes)
    @message = message
  end

  # == Component ==

  sig { override.void }
  def view_template
    div(class: "flex gap-2 items-center justify-center") do
      image_tag(
        "logo.png",
        alt: [ Smallerworld.application.site_name, "logo" ].join(" "),
        class: "size-7",
      )
      Components::Alert(class: "border-dashed py-1.5 px-2 w-auto") do |alert|
        alert.description(class: "italic text-wrap leading-[1.2] font-cursive text-base") do
          @message
        end
      end
    end
  end
end
