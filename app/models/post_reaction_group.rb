# typed: true
# frozen_string_literal: true

class PostReactionGroup < T::Struct
  const :post, Post
  const :emoji, String
  const :count, Integer
  const :current_reaction_id, T.nilable(String)
end
