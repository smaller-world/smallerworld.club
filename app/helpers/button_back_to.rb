# typed: true
# frozen_string_literal: true

module ButtonBackTo
  extend T::Sig
  include ButtonTo

  # == Methods ==

  sig do
    params(
      label: String,
      href: String,
      attributes: T.untyped,
    ).void
  end
  def button_back_to(label, href, **attributes)
    button_to(
      "back to #{label}",
      href,
      icon: "huge/link-backward",
     **attributes,
    )
  end

  def button_back_to_home(**attributes)
    button_back_to("home", home_path, **attributes)
  end
end
