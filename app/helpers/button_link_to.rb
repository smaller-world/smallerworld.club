# typed: true
# frozen_string_literal: true

module ButtonLinkTo
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::HTML }

  include Phlex::Rails::Helpers::Routes

  # == Helper ==

  sig do
    params(
      args: T.untyped,
      icon: T.nilable(String),
      attributes: T.untyped,
      block: T.nilable(T.proc.void),
    ).void
  end
  def button_link_to(*args, icon: nil, **attributes, &block)
    if block_given?
      label = capture(&block)
      target = args.first
    else
      label, target = args
    end

    Components::Button(
      element: :a,
      href: polymorphic_path(target),
      variant: :link,
      **attributes,
    ) do |button|
      if icon.present?
        button.inline_start_icon(icon)
        if block_given?
          raw(label) # rubocop:disable Rails/OutputSafety
        else
          span { label }
        end
      elsif block_given?
        raw(label) # rubocop:disable Rails/OutputSafety
      else
        plain(label)
      end
    end
  end
end
