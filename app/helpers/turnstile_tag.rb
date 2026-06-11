# typed: strict
# frozen_string_literal: true

module TurnstileTag
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::HTML }

  # == Methods ==

  sig { params(action: T.nilable(Symbol), attributes: T.untyped).void }
  def turnstile_tag(action: nil, **attributes)
    div(**mix(
      {
        data: {
          controller: "turnstile",
          turnstile_sitekey_value: Rails.application.credentials.turnstile!.site_key!,
          turnstile_action_value: action,
        },
      },
      attributes,
    ))
  end
end
