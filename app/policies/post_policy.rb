# typed: true
# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  # == Rules ==

  def show?
    user = user!
    post = T.let(record, Post)
    post.visible_to?(user)
  end

  alias_rule :report?, to: :show?

  # World owner can manage post
  def manage?
    post = T.let(record, Post)
    user = user!
    post.world_owner! == user
  end

  def react?
    post = T.let(record, Post)
    user = user!
    post.world_owner! != user && allowed_to?(:show?, post)
  end

  def reply?
    post = T.let(record, Post)
    allowed_to?(:react?, post)
  end

  # == Scopes ==

  scope_for :active_record_relation do |relation|
    relation = T.let(relation, Post::PrivateRelation)
    if (user = self.user)
      relation.visible_to(user)
    else
      relation.none
    end
  end
end
