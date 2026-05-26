# typed: true
# frozen_string_literal: true

class ReactionPolicy < ApplicationPolicy
  # == Rules ==

  def index?
    true
  end

  def show?
    true
  end
end
