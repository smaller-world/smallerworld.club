# typed: true
# frozen_string_literal: true

module TaggedLogging
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Kernel }

  extend ActiveSupport::Concern

  class_methods do
    extend T::Sig
    extend T::Helpers

    requires_ancestor { Module }

    # == Methods ==

    sig do
      returns(T.any(ActiveSupport::Logger, ActiveSupport::BroadcastLogger))
    end
    def logger = Rails.logger

    sig do
      overridable.type_parameters(:U)
        .params(tags: String, block: T.proc.returns(T.type_parameter(:U)))
        .returns(T.type_parameter(:U))
    end
    def tag_logger(*tags, &block)
      T.unsafe(logger).tagged(*log_tags, *tags, &block)
    end

    sig { overridable.returns(T::Array[String]) }
    def log_tags
      tags = T.let([], T::Array[String])
      if (name = self.name)
        tags << name
      end
      tags
    end

    sig { params(tags: T::Array[String]).returns(T.any(ActiveSupport::Logger, ActiveSupport::BroadcastLogger)) }
    def tagged_logger(*tags)
      if logger.respond_to?(:tagged)
        T.unsafe(logger).tagged(*log_tags, *tags)
      else
        logger
      end
    end
  end

  private

  # == Helpers ==

  def logger
    self.class.logger
  end

  sig { overridable.returns(T::Array[String]) }
  def log_tags
    self.class.log_tags
  end

  sig do
    overridable.type_parameters(:U)
      .params(tags: String, block: T.proc.returns(T.type_parameter(:U)))
      .returns(T.type_parameter(:U))
  end
  def tag_logger(*tags, &block)
    if logger.respond_to?(:tagged)
      T.unsafe(logger).tagged(*log_tags, *tags, &block)
    else
      yield
    end
  end

  sig { params(tags: T::Array[String]).returns(T.any(ActiveSupport::Logger, ActiveSupport::BroadcastLogger)) }
  def tagged_logger(*tags)
    if logger.respond_to?(:tagged)
      T.unsafe(logger).tagged(*log_tags, *tags)
    else
      logger
    end
  end
end
