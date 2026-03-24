# typed: true
# frozen_string_literal: true

class PublicController < ApplicationController
  abstract!

  # == Filters ==

  allow_unauthenticated_access
end
