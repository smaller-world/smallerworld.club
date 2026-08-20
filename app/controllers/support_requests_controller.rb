# typed: true
# frozen_string_literal: true

class SupportRequestsController < PublicController
  # == Actions ==

  # GET /support/new
  def new
    respond_to do |format|
      format.html do
        render Views::SupportRequests::New.new(email_address:)
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "app_layout",
          renderable: Components::AutoclickingLink.new(href: "mailto:#{email_address}"),
        )
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def email_address
    @email_address ||= T.let(
      ActionMailer::Base.email_address_with_name(
        SmallerWorld.application.contact_email,
        "smaller world team",
      ),
      T.nilable(String),
    )
  end
end
