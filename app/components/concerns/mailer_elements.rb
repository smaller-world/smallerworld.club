# typed: strict
# frozen_string_literal: true

module MailerElements
  extend T::Sig
  extend T::Helpers
  include Phlex::Rails::Helpers::URLFor

  requires_ancestor { Phlex::HTML }

  # == Methods ==

  sig do
    params(
      target: Object,
      attributes: T.untyped,
      content: T.proc.void,
    ).void
  end
  def email_button_to(target, **attributes, &content)
    a(
      href: url_for(target), **mix(
        {
          class: "inline-block rounded-4xl border border-transparent bg-primary pl-3 pr-3 pt-2 pb-2 text-primary-foreground [text-decoration:none] font-medium font-heading",
        },
        attributes,
      ),
      &content
    )
  end
end
