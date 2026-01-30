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

  sig do
    params(label: String, options: T.untyped, html_options: T.untyped)
      .returns(String)
  end
  def back_link_to(label, options, **html_options)
    link_class = html_options.delete(:class)
    link_to(
      options,
      class: class_names("btn native:hidden", link_class),
      **html_options,
    ) do
      icon("arrow-uturn-left", variant: :micro, class: "size-5") +
        tag.span("back to #{label}", class: "overflow-ellipsis")
    end
  end

  sig do
    params(hash: T::Hash[Symbol, T.untyped], keys: Symbol)
      .returns(T::Hash[Symbol, T.untyped])
  end
  def delete_from(hash, *keys)
    removed_values = {}
    keys.each do |key|
      removed_values[key] = hash.delete(key) if hash.key?(key)
    end
    removed_values
  end
end
