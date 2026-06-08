# typed: true
# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  # == Rules ==

  def show?
    user = user!
    post = T.let(record, Post)
    post.author! == user || (
      if (key_colors = post.key_colors)
        WorldKey.exists?(world_id: post.world_id, recipient: user, color: key_colors)
      else
        WorldKey.exists?(world_id: post.world_id, recipient: user)
      end
    )
  end

  # World owner can manage post
  def manage?
    post = T.let(record, Post)
    user = user!
    post.author! == user
  end

  def react?
    post = T.let(record, Post)
    user = user!
    post.author! != user &&
      WorldKey.exists?(world_id: post.world_id, recipient: user)
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
