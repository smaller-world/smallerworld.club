# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(String) }
  def v1_url
    config.v1_url
  end
end
