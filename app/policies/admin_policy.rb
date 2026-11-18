# typed: true
# frozen_string_literal: true

# Controls access to the admin area.
class AdminPolicy < ApplicationPolicy
  # == Rules ==

  def manage?
    Rails.env.development? || user!.admin?
  end
end
