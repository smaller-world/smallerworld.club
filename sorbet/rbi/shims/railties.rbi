# typed: true

module Rails
  class << self
    sig { returns(T.all(ActiveSupport::Logger, ActiveSupport::TaggedLogging)) }
    def logger; end
  end

  class Command::Base; end
end
