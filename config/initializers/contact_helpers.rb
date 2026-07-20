# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(String) }
  def contact_email
    credentials.contact!.email!
  end
end
