# typed: true
# frozen_string_literal: true

module ApplicationHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }
end
