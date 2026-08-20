# typed: strict
# frozen_string_literal: true

class Components::AutoclickingLink < Components::Base
  # == Initialization ==

  sig do
    params(
      href: String,
      attributes: T.untyped,
    ).void
  end
  def initialize(href:, **attributes)
    super(**attributes)
    @href = href
  end

  # == Component ==

  sig { override.void }
  def view_template
    root_element(
      :a,
      href: @href,
      hidden: true,
      data: {
        turbo: false,
        controller: "autoclick",
        autoclick_once_value: true,
      },
    )
  end
end
