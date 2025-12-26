# typed: true
# frozen_string_literal: true

class PostReactionGroup < T::Struct
  const :emoji, String
  const :count, Integer
  const :reacted, T::Boolean
end
