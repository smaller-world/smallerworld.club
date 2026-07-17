# typed: true
# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/account_mailer
class AccountMailerPreview < ActionMailer::Preview
  def email_address_confirmation
    user = User.new(name: "bobby sue", unconfirmed_email_address: "bobby.sue@example.com")
    AccountMailer.email_address_confirmation(user:)
  end
end
