# typed: strict
# frozen_string_literal: true

module BooleanParams
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ActionController::Base }

  private

  # == Methods ==

  sig { params(value: T.untyped).returns(T::Boolean) }
  def cast_boolean(value)
    if value
      ActiveModel::Type::Boolean.new.cast(value)
    else
      false
    end
  end
end
