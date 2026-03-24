# typed: true

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

class ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  include SessionTestHelper

  sig { params(block: T.proc.bind(T.attached_class).void).void }
  def self.test(&block)
  end
end
