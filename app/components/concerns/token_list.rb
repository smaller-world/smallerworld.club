# typed: strict
# frozen_string_literal: true

module TokenList
  extend T::Sig
  extend T::Helpers

  # == Methods ==

  # Like +ActionView::Helpers::TagHelper#token_list+, but does not HTML-escape
  # the resulting tokens (so characters like +->+ survive intact).
  sig { params(args: T.untyped).returns(String) }
  private def token_list(*args)
    build_token_values(*T.unsafe(args))
      .flat_map { |value| value.to_s.split(/\s+/) }
      .uniq
      .join(" ")
  end

  private

  # == Helpers ==

  sig { params(args: T.untyped).returns(T::Array[T.untyped]) }
  def build_token_values(*args)
    values = []
    args.each do |value|
      case value
      when Hash
        value.each do |key, val|
          values << key.to_s if val && key.present?
        end
      when Array
        values.concat(build_token_values(*T.unsafe(value)))
      else
        values << value if value.present?
      end
    end
    values
  end
end
