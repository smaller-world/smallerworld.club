# typed: true
# frozen_string_literal: true

module Admin
  # Base class for policies guarding the admin area.
  #
  # Deliberately separate from the non-namespaced policies: `ReportPolicy` and
  # friends answer "is this yours?" for the people who own the records, while
  # these answer "are you an admin?". Both apply to the same model classes, so
  # admin controllers must pass `with: Admin::SomePolicy` explicitly.
  class AdminPolicy < ApplicationPolicy
    # == Rules ==

    def index?
      admin?
    end

    def show?
      admin?
    end

    private

    # == Helpers ==

    sig { returns(T::Boolean) }
    def admin?
      Rails.env.development? || user!.admin?
    end
  end
end
