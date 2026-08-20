# typed: strict
# frozen_string_literal: true

class Views::SupportRequests::New < Views::Base
  # == Initialization ==

  sig { params(email_address: String).void }
  def initialize(email_address:)
    super()
    @email_address = email_address
    @mailto_url = T.let("mailto:#{@email_address}", String)
  end

  # == View ==

  sig { override.void }
  def view_template
    doctype
    html do
      head do
        meta(
          http_equiv: safe("refresh"),
          content: "0; url=#{@mailto_url}",
        )
      end
      body do
        link_to(@mailto_url, "contact the smaller world team")
      end
    end
  end
end
