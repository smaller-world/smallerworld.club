# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(Integer) }
  def ios_store_identifier
    credentials.ios!.store_identifier!
  end
end
