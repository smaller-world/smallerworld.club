# typed: true
# frozen_string_literal: true

module ButtonLinkTo
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::HTML }

  include Phlex::Rails::Helpers::Routes

  # == Methods ==

  sig do
    params(
      label: String,
      href: String,
      icon: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def button_link_to(label, href, icon: nil, **attributes)
    Components::Button(
      element: :a,
      href:,
      variant: :secondary,
      **attributes,
    ) do |button|
      if icon.present?
        button.icon(icon, align: "inline-start")
        span { label }
      else
        label
      end
    end
  end
end
