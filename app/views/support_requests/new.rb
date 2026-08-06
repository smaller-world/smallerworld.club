# typed: strict
# frozen_string_literal: true

class Views::SupportRequests::New < Views::Base
  # == Initialization ==

  sig { void }
  def initialize
    super
    @email_address = T.let(
      ActionMailer::Base.email_address_with_name(
        SmallerWorld.application.contact_email,
        "smaller world team",
      ),
      String,
    )
  end

  # == View ==

  sig { override.void }
  def view_template
    doctype
    html do
      head do
        meta(
          http_equiv: safe("refresh"),
          content: "0; url=mailto:#{@email_address}",
        )
      end
    end
  end
end
