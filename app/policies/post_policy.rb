# typed: true
# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  # == Rules ==

  def show?
    user = user!
    post = T.let(record, Post)
    post.author! == user ||
      WorldKey.exists?(world_id: post.world_id, recipient: user)
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
end
