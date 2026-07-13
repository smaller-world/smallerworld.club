# typed: strict
# frozen_string_literal: true

module ButtonLinkTo
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::HTML }

  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::URLFor

  # == Methods ==

  sig do
    params(
      args: T.untyped,
      icon: T.nilable(String),
      icon_class: T.nilable(String),
      attributes: T.untyped,
      content: T.nilable(T.proc.returns(T.anything)),
    ).void
  end
  def button_link_to(*args, icon: nil, icon_class: nil, **attributes, &content)
    if args.size > 1
      label, target = args
    else
      label_html = capture(&content) if content
      target = args.first
    end

    Components::Button(
      element: :a,
      href: url_for(target),
      variant: :link,
      **attributes,
    ) do |button|
      if icon.present?
        button.inline_start_icon(icon, class: icon_class)
        if label_html
          raw(label_html) # rubocop:disable Rails/OutputSafety
        elsif label
          span { label }
        end
      elsif label_html
        raw(label_html) # rubocop:disable Rails/OutputSafety
      else
        plain(label)
      end
    end
  end
end
