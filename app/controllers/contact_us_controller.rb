# typed: true
# frozen_string_literal: true

class ContactUsController < ApplicationController
  # == Actions ==

  # POST /contact_us/sms
  def sms
    uri = ContactUs.sms_uri
    if (body = params[:body])
      uri.query_values = { body: }
    end
    redirect_to(uri.to_s, allow_other_host: true)
  end

  # POST /contact_us/email
  def email
    uri = ContactUs.mailto_uri
    query_values = T.let({}, T::Hash[Symbol, String])
    if (subject = params[:subject])
      query_values[:subject] = subject
    end
    if (body = params[:body])
      query_values[:body] = body
    end
    uri.query_values = query_values
    redirect_to(uri.to_s, allow_other_host: true)
  end

  private

  # == Helpers ==

  sig { returns(ActionController::Parameters) }
  def message_params
    params.expect(contact_us_message: %i[subject body])
  end
end
