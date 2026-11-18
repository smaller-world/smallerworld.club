# typed: strict
# frozen_string_literal: true

class AdminController < ApplicationController
  abstract!

  # == Filters ==

  before_action :verify_admin!

  private

  # == Callbacks ==

  sig { void }
  def verify_admin!
    authorize!(to: :manage?, with: AdminPolicy)
  end
end
