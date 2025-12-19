# typed: true
# frozen_string_literal: true

module ApplicationHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }
  requires_ancestor { RailsIcons::Helpers::IconHelper }

  # == Methods ==

  sig { returns(String) }
  def page_title_tag
    tag.title([ @page_title, "smaller world" ].compact.join(" | "))
  end

  sig { params(label: String, url: String, options: T.untyped).returns(String) }
  def back_link_to(label, url, **options)
    link_to(url, class: "btn native:hidden", **options) do
      icon("arrow-uturn-left", variant: :micro, class: "size-5") +
        tag.span("back to #{label}", class: "overflow-ellipsis")
    end
  end
end
