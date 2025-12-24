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
    when "response"
      icon("chat-bubble-oval-left", variant:, **options)
    else
      raise NotImplementedError, "Unknown post type: #{type}"
    end
  end

  sig { returns(T::Set[String]) }
  def selectable_post_types
    @selectable_post_types ||= %w[journal_entry poem invitation question].to_set
  end

  sig { params(type: String).returns(T.nilable(String)) }
  def post_title_placeholder(type:)
    case type
    when "journal_entry"
      "what a day!"
    when "poem"
      "the invisible mirror"
    when "invitation"
      "bake night 2!!"
    end
  end

  sig { params(type: String).returns(T.nilable(String)) }
  def post_body_placeholder(type:)
    case type
    when "journal_entry"
      "today felt kind of surreal. almost like a dream..."
    when "poem"
      <<~EOF
        broken silver eyes cry me a thousand mirrors
        beautiful reflections of personal nightmares
        the sort i save for my therapist's office
        and of course the pillowcase i water every night
      EOF
    when "invitation"
      "i'm going to https://lu.ma/2323 tonight! pls come out if you're free :)"
    when "question"
      "liberty village food recs??"
    when "follow_up"
      "um, actually..."
    end
  end
end
