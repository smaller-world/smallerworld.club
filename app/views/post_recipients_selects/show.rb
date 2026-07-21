# typed: strict
# frozen_string_literal: true

class Views::PostRecipientsSelects::Show < Views::Base
  # == Initialization ==

  sig { params(post_type: PostType).void }
  def initialize(post_type:)
    super()
    @post_type = post_type
    @post = T.let(@post_type.posts.build, Post)
  end

  # == View ==

  sig { override.void }
  def view_template
    turbo_frame_tag(:recipients_select) do
      Components::PostRecipientsSelect(
        post: @post,
        input_id_prefix: "post_recipient_ids",
        name: "post[recipient_ids][]",
        value: @post_type.recipient_ids,
      )
    end
  end
end
