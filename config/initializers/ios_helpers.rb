# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  sig { returns(String) }
  def testflight_url
    config.testflight_url
  end

  sig { returns(Integer) }
  def ios_store_identifier
    credentials.ios!.store_identifier!
  end
end
