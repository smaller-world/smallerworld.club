# typed: strict

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
end

class ActiveSupport::ContinuousIntegration
  sig do
    params(
      title: T.untyped,
      subtitle: T.untyped,
      block: T.proc.bind(T.attached_class).void,
    ).void
  end
  def self.run(title = nil, subtitle = nil, &block)
  end
end
