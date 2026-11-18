# typed: true
# frozen_string_literal: true

class ReflectionPolicy < ApplicationPolicy
  # == Rules ==

  # Reflection author can manage reflection
  def manage?
    reflection = T.let(record, Reflection)
    user = user!
    user == reflection.author!
  end

  # == Scopes ==

  scope_for :active_record_relation do |relation|
    relation = T.let(relation, Reflection::PrivateRelation)
    if (user = self.user)
      relation.where(author: user)
    else
      relation.none
    end
  end
end
