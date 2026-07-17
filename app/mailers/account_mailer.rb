# typed: strict
# frozen_string_literal: true

class AccountMailer < ApplicationMailer
  # == Actions ==

  sig { params(user: User).void }
  def email_address_confirmation(user:)
    render_email(
      Views::Mailers::Accounts::EmailAddressConfirmation.new(user:),
      subject: "confirm your email address :)",
      to: email_address_with_name(user.unconfirmed_email_address!, user.name),
    )
  end
end
