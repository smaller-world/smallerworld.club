# typed: strict
# frozen_string_literal: true

module Post::ReplyUrl
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  abstract!
  requires_ancestor { Post }

  # == Methods ==

  sig { params(platform: Symbol, native: T::Boolean).returns(String) }
  def reply_url(platform:, native: false)
    message = reply_snippet_for(platform)
    author!.dm_url(platform:, message:, native:)
  end

  private

  # == Helpers ==

  sig { params(platform: Symbol).returns(String) }
  def reply_snippet_for(platform)
    if platform == :whatsapp
      "> " + snippet.gsub("\n", "\n>\u2800") + "\n\n\u2800"
    else
      "> " + snippet.gsub("\n", "\n> ") + "\n\n"
    end
  end
end
