# typed: true
# frozen_string_literal: true

class WorldCardPolicy < ApplicationPolicy
  # == Rules ==

  def show?
    card = T.let(record, WorldCard)
    card.unclaimed? || card.cardholder == user!
  end

  alias_rule :download?, :claim?, to: :show?
end
