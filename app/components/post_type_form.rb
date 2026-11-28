# typed: strict
# frozen_string_literal: true

class Components::PostTypeForm < Components::Base
  # == Initialization ==

  sig do
    params(
      post_type: PostType,
      return_url: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def initialize(post_type:, return_url: nil, **attributes)
    super(**attributes)
    @post_type = post_type
    @return_url = return_url

    @world = T.let(@post_type.world!, World)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @post_type,
      action:,
      vibrate_on_submit: true,
    ) do |form|
      if (return_url = @return_url)
        input(type: "hidden", name: "return_to", value: return_url)
      end

      form.wrapped(
        form.field(:name).text(
          placeholder: @post_type.name.presence || "journal entry",
          required: true,
        ),
        label: "what's this post type called?",
      )

      # Components::FieldSet(class: "gap-1") do |field_set|
      #   field_set.legend(class: "mb-0") do
      #     "are these posts loud or quiet?"
      #   end
      #   field_set.description do
      #     "you can change this setting on a per-post basis"
      #   end
      #   radio_group_for(form, :quiet, class: "mt-2") do |radio_group|
      #     choice_card_for(:off, radio_group:) do |field|
      #       Icon("huge/notification-01", class: "size-4 mt-0.5")
      #       div(class: "flex-1 flex flex-col gap-0.5") do
      #         field.title do
      #           "loud by default"
      #         end
      #         field.description do
      #           "loud posts appear in your world and generate a notification when posted"
      #         end
      #       end
      #     end
      #     choice_card_for(:on, radio_group:, class: "border-dashed") do |field|
      #       Icon("huge/notification-snooze-01", class: "size-4 mt-0.5")
      #       div(class: "flex-1 flex flex-col gap-0.5") do
      #         field.title do
      #           "quiet by default"
      #         end
      #         field.description do
      #           "quiet posts are hidden in their own section, and " \
      #             "do not generate a notification when posted"
      #         end
      #       end
      #     end
      #   end
      # end

      form.submit do |button|
        if @post_type.new_record?
          button.inline_start_icon("huge/plus-sign-square")
          span { "create post type" }
        else
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Object) }
  def action
    @post_type.new_record? ? [ @world, @post_type ] : @post_type
  end
end
