# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  sig { returns(String) }
  def v1_url
    config.x.v1_url
  end
end
