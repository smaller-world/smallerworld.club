# typed: true
# frozen_string_literal: true

module PostsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }
  requires_ancestor { RailsIcons::Helpers::IconHelper }

  # == Methods ==

  sig do
    params(type: String, variant: Symbol, options: T.untyped).returns(String)
  end
  def post_type_icon(type, variant: :micro, **options)
    case type
    when "journal_entry"
      icon("notebook", library: :phosphor, fill: "currentColor", **options)
    when "poem"
      icon("scroll", library: :phosphor, fill: "currentColor", **options)
    when "invitation"
      icon("envelope", variant:, **options)
    when "question"
      icon("question-mark-circle", variant:, **options)
    when "follow_up"
      icon("arrow-path-rounded-square", variant:, **options)
    else
      raise NotImplementedError, "Unknown post type: #{type}"
    end
  end
end
