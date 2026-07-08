# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(String) }
  def testflight_invitation_code
    config.testflight_invitation_code
  end

  sig { returns(String) }
  def testflight_url
    "https://testflight.apple.com/join/#{testflight_invitation_code}"
  end

  sig { returns(Integer) }
  def ios_store_identifier
    credentials.ios!.store_identifier!
  end
end
