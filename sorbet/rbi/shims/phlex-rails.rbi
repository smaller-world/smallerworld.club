# typed: true
# frozen_string_literal: true

module Phlex::Rails
  class Builder
    include ActionView::Helpers::FormHelper

    def button(value = T.unsafe(nil), options = T.unsafe(nil), &block); end
    def field_id(method, *suffixes, namespace: T.unsafe(nil), index: T.unsafe(nil)); end
    def field_name(method, *methods, multiple: T.unsafe(nil), index: T.unsafe(nil)); end
    def object; end
  end

  module Helpers::FormWith
    sig do
      params(
        args: T.untyped,
        kwargs: T.untyped,
        block: T.proc.params(form: Builder).void,
      ).void
    end
    def form_with(*args, **kwargs, &block); end
  end
end
