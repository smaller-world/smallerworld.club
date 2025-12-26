# typed: true
# frozen_string_literal: true

module ApplicationHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  # == Methods ==

  sig { returns(T.nilable(String)) }
  def page_title
    if hotwire_native_app?
      @page_title
    else
      [ @page_title, "smaller world" ].compact.join(" | ")
    end
  end


  sig { returns(T.nilable(String)) }
  def hotwire_native_data_attribute
    if hotwire_native_app?
      ""
    end
  end

  sig { params(label: String, url: String, options: T.untyped).returns(String) }
  def back_link_to(label, url, **options)
    link_to(url, class: "btn native:hidden", **options) do
      icon("arrow-uturn-left", variant: :micro, class: "size-5") +
        tag.span("back to #{label}", class: "overflow-ellipsis")
    end
  end

  sig { params(options: T.untyped).returns(String) }
  def new_session_with_redirect_path(**options)
    new_session_path(redirect_to: request.fullpath, **options)
  end
end
