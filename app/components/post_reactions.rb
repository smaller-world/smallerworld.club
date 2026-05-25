# typed: strict
# frozen_string_literal: true

class Components::PostReactions < Components::Base
  # == Initialization ==

  sig { params(post: Post, new_reaction: Reaction, attributes: T.untyped).void }
  def initialize(post:, new_reaction: post.reactions.build, **attributes)
    @post = post
    @reactions_by_emoji = T.let(
      @post.reactions.chronological.group_by(&:emoji),
      T::Hash[String, T::Array[Reaction]],
    )
    @new_reaction = new_reaction
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    root_element(:div, class: "flex flex-wrap gap-1") do
      @reactions_by_emoji.each do |emoji, reactions|
        current_user_reaction = if (user = @current_user)
          reactions.find { |r| r.reactor_id == user.id }
        end
        form_with(
          model: current_user_reaction || [ @post, @post.reactions.build(emoji:) ],
          method: current_user_reaction ? :delete : :post,
        ) do |form|
          form.hidden_field(:emoji)
          submit_button_for(
            form,
            variant: current_user_reaction ? :outline : :ghost,
            size: reactions.size > 1 ? :default : :icon,
            class: class_names(
              "rounded-full gap-x-1",
              "px-2" => reactions.size > 1,
            ),
          ) do
            span(class: class_names(
              "font-emoji",
              reactions.size > 1 ? "text-base" : "text-lg",
            )) do
              emoji
            end
            if reactions.size > 1
              span(class: "text-xs") { reactions.size }
            end
          end
        end
      end
      Components::ReactionForm(
        reaction: @new_reaction,
        variant: @reactions_by_emoji.any? ? :ghost : :default,
      )
    end
  end
end
