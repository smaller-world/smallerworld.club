# typed: strict
# frozen_string_literal: true

class Components::AutoclickingReplyLink < Components::Base
  # == Initialization ==

  sig { params(reply_initiation: ReplyInitiation, attributes: T.untyped).void }
  def initialize(reply_initiation:, **attributes)
    super(**attributes)
    @reply_initiation = reply_initiation
  end

  sig { override.void }
  def view_template
    a(
      href: @reply_initiation.reply_url(native: hotwire_native_app?),
      hidden: true,
      data: {
        turbo: false,
        controller: "autoclick",
        autoclick_once_value: true,
      },
    )
  end
end
