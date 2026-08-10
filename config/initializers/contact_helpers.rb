# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  sig { returns(String) }
  def contact_email
    credentials.contact!.email!
  end

  sig { returns(String) }
  def support_email
    credentials.contact!.support_email!
  end
end
