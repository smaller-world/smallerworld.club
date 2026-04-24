# typed: true
# frozen_string_literal: true

ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  # Return the original HTML without wrapping
  html_tag.html_safe # rubocop:disable Rails/OutputSafety
end
