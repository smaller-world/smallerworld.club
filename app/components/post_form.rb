# typed: true
# frozen_string_literal: true

class Components::PostForm < Components::Base
  # == Initialization ==

  sig { params(post: Post, options: T.untyped).void }
  def initialize(post:, **options)
    @post = post
    @world = T.let(post.world!, World)
    @options = T.let(options, T::Hash[Symbol, T.untyped])
    super()
  end

  # == Component ==

  sig { override.void }
  def view_template
    component_form_with(
      model: @post,
      url: world_posts_path(@world),
      class: "flex flex-col gap-y-4",
      **@options,
    ) do |form|
      form.field(:title) do |f|
        f.text_input(placeholder: "a title!")
        f.error
      end
      form.field(:plain_body) do |f|
        f.textarea(
          placeholder: "something i want to share...",
          required: true,
          class: "min-h-36",
        )
        f.error
      end
      form.button do |button|
        if @post.new_record?
          button.inline_start_icon("huge/mail-send-01")
          span { "submit" }
        else
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end
end
