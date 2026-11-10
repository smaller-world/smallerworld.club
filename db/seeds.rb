# typed: strict
# frozen_string_literal: true

if Rails.env.development?
  require_relative "seeds/development"
  DevelopmentData.seed!
end
