# typed: true
# frozen_string_literal: true

require "lexxy"

# Lexxy emits `<s>` for strikethrough, but `Rails::HTML4::SafeListSanitizer`'s
# `DEFAULT_ALLOWED_TAGS` only includes `<del>` (the tag Trix used). Lexxy's own
# `lexxy.sanitization` engine initializer extends `ActionText::ContentHelper
# .allowed_tags` for media/table tags but leaves `<s>` out, so strikethrough
# content gets silently stripped on render. Append `<s>` to the allowlist on
# top of whatever Lexxy configured.
#
# Registered via `after_initialize` so our `on_load` callback queues *after*
# Lexxy's `lexxy.sanitization` engine initializer — otherwise `allowed_tags`
# may still be `nil` when we run and `<<` blows up.
#
# See: https://github.com/basecamp/lexxy/discussions/944
Rails.application.config.after_initialize do
  ActiveSupport.on_load(:action_text_content) do
    ActionText::ContentHelper.allowed_tags << "s"
  end
end
