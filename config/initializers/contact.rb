# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  sig { returns(String) }
  def contact_email_address
    with_fallback_email_for_ci do
      credentials.contact!.email!
    end
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
    with_fallback_email_for_ci do
      credentials.contact!.support_email!
    end
  end

  sig { returns(String) }
  def support_email_address_with_name
    ActionMailer::Base.email_address_with_name(
      support_email_address,
      "smaller world support",
    )
  end

  private

  # == Helpers ==

  sig { params(block: T.proc.returns(String)).returns(String) }
  def with_fallback_email_for_ci(&block)
    yield
  rescue KeyError
    "email@example.com"
  end
end
