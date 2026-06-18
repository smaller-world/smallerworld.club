# typed: strict

# module ActionController::RateLimiting::ClassMethods
#   sig do
#     params(
#       to: Integer,
#       within: ActiveSupport::Duration,
#       by: T.nilable(T.proc.returns(String)),
#       with: T.nilable(T.proc.bind(T.attached_class).void),
#       store: T.nilable(ActiveSupport::Cache::Store),
#       name: T.nilable(String),
#       scope: T.nilable(String),
#       options: T.untyped,
#     ).void
#   end
#   def rate_limit(to:, within:, by: T.unsafe(nil), with: T.unsafe(nil), store: T.unsafe(nil), name: T.unsafe(nil), scope: T.unsafe(nil), **options); end
# end

class ActionText::RichText
  sig { returns(ActionText::Content) }
  def body; end
end

class ActionText::Content
  sig { returns(ActionText::Fragment) }
  def fragment; end
end

class ActionText::Fragment
  sig { returns(Nokogiri::HTML5::DocumentFragment) }
  def source; end
end
