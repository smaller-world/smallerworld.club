# typed: strict
# frozen_string_literal: true

class Components::PostReactions < Components::Base
  # == Initialization ==

  sig do
    params(
      post: Post,
      new_reaction: Reaction,
      async: T::Boolean,
      existing_reactions_form: T::Hash[Symbol, T.untyped],
      new_reaction_form: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    post:,
    new_reaction: post.reactions.build,
    async: false,
    existing_reactions_form: {},
    new_reaction_form: {},
    **attributes
  )
    super(**attributes)
    @post = post
    @reactions_by_emoji = T.let(
      @post.reactions.chronological.group_by(&:emoji),
      T::Hash[String, T::Array[Reaction]],
    )
    @new_reaction = new_reaction
    @async = async
    @existing_reactions_form_options = existing_reactions_form
    @new_reaction_form_options = new_reaction_form
  end

  # == Component ==

  sig { override.void }
  def view_template
    turbo_frame_tag(
      dom_id(@post, :reactions),
      src: ([ @post, :reactions ] if @async),
      loading: :lazy,
      **mix(
        {
          class: "flex-1 flex justify-end flex-wrap gap-1",
          data: {
            controller: "frame",
          },
        },
        @attributes,
      ),
    ) do
      if @async
        # Render placeholder
        Components::Button(
          element: :div,
          variant: :ghost,
          size: :icon,
          class: "rounded-full skeleton",
        ) do
          span(class: "font-emoji text-lg") do
            "🤣"
          end
        end
      else
        @reactions_by_emoji.each do |emoji, reactions|
          render Components::ExistingReactionForm.new(
            post: @post,
            emoji:,
            reactions:,
            **mix(
              {
                data: {
                  action: "turbo:before-fetch-response->frame#reloadWhenNotFound",
                },
              },
              @existing_reactions_form_options,
            ),
          )
        end
        if allowed_to?(:react?, @post)
          render Components::NewReactionForm.new(
            reaction: @new_reaction,
            variant: @reactions_by_emoji.any? ? :ghost : :default,
            **@new_reaction_form_options,
          )
        end
      end
    end
  end
end
