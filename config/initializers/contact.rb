# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  sig { returns(String) }
  def contact_email_address
    credentials.contact!.email!
  end

  sig { returns(String) }
  def contact_email_address_with_name
    ActionMailer::Base.email_address_with_name(
      contact_email_address,
      "smaller world team",
    )
  end

  sig { returns(String) }
  def support_email_address
    credentials.contact!.support_email!
  end

  sig { returns(String) }
  def support_email_address_with_name
    ActionMailer::Base.email_address_with_name(
      support_email_address,
      "smaller world support",
    )
  end
end
