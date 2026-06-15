# typed: true
# frozen_string_literal: true

require "delegate"
require "lexxy"

# Lexxy renders an editor's initial value from `body_before_type_cast`, which
# bypasses type-casting. For `ActionText::EncryptedRichText` that raw value is
# the *ciphertext* (decryption happens during type-casting), so the editor would
# show encrypted gibberish. Substitute a decrypted view of the record before
# Lexxy reads it — exposing the plaintext, attachment-node-preserving HTML that a
# plaintext `RichText` would have returned — so Lexxy's own attachment rendering
# still runs.
module Lexxy
  module TagHelper
    module RenderEncryptedContent
      extend T::Sig
      extend T::Helpers

      requires_ancestor { Lexxy::TagHelper }

      # Stands in for an encrypted rich text record, returning its decrypted body
      # where Lexxy expects the un-type-cast value.
      class DecryptedRichText < SimpleDelegator
        # The serialization coder dumps `ActionText::Content` via `to_html`, so a
        # plaintext record's `body_before_type_cast` equals `body.to_html`. Return
        # the same thing here, just decrypted — attachment nodes left intact.
        def body_before_type_cast
          __getobj__.body&.to_html
        end
      end

      sig { params(value: T.untyped).returns(T.untyped) }
      def render_custom_attachments_in(value)
        value = DecryptedRichText.new(value) if value.is_a?(ActionText::EncryptedRichText)
        super
      end
    end

    prepend RenderEncryptedContent
  end
end
