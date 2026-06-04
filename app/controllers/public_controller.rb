# typed: strict
# frozen_string_literal: true

class PublicController < ApplicationController
  abstract!

  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized
end
