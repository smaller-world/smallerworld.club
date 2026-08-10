# typed: true
# frozen_string_literal: true

module Admin
  class ReportPolicy < AdminPolicy
    # == Rules ==

    def resolve?
      admin?
    end

    # == Scopes ==

    scope_for :active_record_relation do |relation|
      relation = T.let(relation, Report::PrivateRelation)
      if user&.admin?
        relation
      else
        relation.none
      end
    end
  end
end
