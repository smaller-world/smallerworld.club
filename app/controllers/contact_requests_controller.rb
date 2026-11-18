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

  # POST /contact?purpose=(inquiry|support|feedback)
  def create
    respond_to do |format|
      format.turbo_stream do
        purpose = params[:purpose]
        case purpose
        when "feedback"
          phone_number = contact_phone_number
          render turbo_stream: append_sms_contact_link(phone_number:)
        else
          email_address = contact_email_address(purpose:)
          render turbo_stream: append_email_contact_link(email_address:)
        end
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

  sig { returns(String) }
  def contact_phone_number
    SmallerWorld.application.contact_phone_number
  end

  sig { params(email_address: String).returns(ActiveSupport::SafeBuffer) }
  def append_email_contact_link(email_address:)
    turbo_stream.append(
      "contact_links",
      renderable: Components::AutoclickingLink.new(href: "mailto:#{email_address}"),
    )
  end

  sig { params(phone_number: String).returns(ActiveSupport::SafeBuffer) }
  def append_sms_contact_link(phone_number:)
    turbo_stream.append(
      "contact_links",
      renderable: Components::AutoclickingLink.new(href: "sms:#{phone_number}"),
    )
  end
end
