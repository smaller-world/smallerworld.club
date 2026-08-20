# typed: true
# frozen_string_literal: true

class ContactRequestsController < PublicController
  # == Actions ==

  # GET /contact?type=(inquiry|support)
  def new
    respond_to do |format|
      format.html do
        render Views::ContactRequests::New
      end
    end
  end

  # POST /contact?purpose=(inquiry|support)
  def create
    respond_to do |format|
      format.turbo_stream do
        purpose = params[:purpose]
        email_address = contact_email_address(purpose:)
        render turbo_stream: turbo_stream.append(
          "contact_links",
          renderable: Components::AutoclickingLink.new(href: "mailto:#{email_address}"),
        )
      end
    end
  end

  private

  # == Helpers ==

  sig { params(purpose: String).returns(String) }
  def contact_email_address(purpose:)
    case purpose
    when "support"
      SmallerWorld.application.support_email_address_with_name
    else
      SmallerWorld.application.contact_email_address_with_name
    end
  end
end
