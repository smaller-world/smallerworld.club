# typed: strict
# frozen_string_literal: true

class Components::ExistingPostReactionForm < Components::Base
  include Phlex::Rails::Helpers::FormWith
  include NormalizeAttributes

  # == Initialization ==

  sig do
    params(
      post: Post,
      emoji: String,
      reactions: T::Array[Reaction],
      attributes: T.untyped,
    ).void
  end
  def initialize(post:, emoji:, reactions:, **attributes)
    super(**attributes)
    @post = post
    @emoji = emoji
    @reactions = reactions
    @reactions_count = T.let(reactions.count, Integer)
    @current_user_reaction = T.let(
      if @current_user
        reactions.find do |reaction|
          reaction.reactor == @current_user
        end
      end,
      T.nilable(Reaction),
    )
    @reaction = T.let(@current_user_reaction || @post.reactions.build(emoji: @emoji), Reaction)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @reaction,
      action: @reaction.new_record? ? [ @post, @reaction ] : @reaction,
      method: @reaction.new_record? ? :post : :delete,
      **mix(
        {
          data: {
            controller: token_list(
              "haptic-bridge",
              "confetti" => !@current_user_reaction,
            ),
            action: token_list(
              "turbo:submit-end->confetti#launch",
              "turbo:submit-end->haptic-bridge#vibrate" => !@current_user_reaction,
            ),
            confetti_emoji_value: @emoji,
            confetti_canvas_id_value: Rails.configuration.confetti_canvas_id,
          },
        },
        @attributes,
      ),
    ) do |form|
      unless @current_user_reaction
        form.Field(:emoji).hidden
      end

      form.submit(
        variant: button_variant,
        size: @reactions_count > 1 ? :default : :icon,
        disabled: !allowed_to?(:react?, @post),
        class: class_names(
          "opacity-100 rounded-full",
          "gap-x-1 px-2" => @reactions_count > 1,
        ),
        data: {
          confetti_target: "position",
        },
      ) do
        span(class: class_names(
          "font-emoji align-middle",
          @reactions_count > 1 ? "text-base" : "text-lg",
        )) do
          @emoji
        end
        if @reactions_count > 1
          span(class: "text-xs") do
            @reactions_count
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Symbol) }
  def button_variant
    if !allowed_to?(:react?, @post)
      :secondary
    else
      @current_user_reaction ? :outline : :ghost
    end
  end
end
