# typed: true
# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  # == Rules ==

  def show?
    true
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
    post.author! != user
  end
end
