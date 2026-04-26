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
    form_with(model:, class: "flex flex-col gap-y-4", **@options) do |form|
      field_for(form, :title) do |f|
        f.text_input(placeholder: "a title!")
        f.error
      end
      field_for(form, :body) do |f|
        f.lexxy_editor(
          placeholder: "something i want to share...",
          required: true,
          class: "min-h-36",
        )
        f.error
      end
      submit_button_for(form) do |button|
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

  private

  # == Helpers ==

  sig { returns(Object) }
  def model
    if @post.new_record?
      [ @world, @post ]
    else
      @post
    end
  end
end
