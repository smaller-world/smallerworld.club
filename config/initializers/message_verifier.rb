# typed: strict
# frozen_string_literal: true

Rails.application.message_verifiers.prepend(serializer: :message_pack, url_safe: true)
