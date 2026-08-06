# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  sig { returns(String) }
  def site_name
    Rails.configuration.x.site.name
  end

  sig { returns(String) }
  def email_disclaimer
    Rails.configuration.email_disclaimer
  end
end
