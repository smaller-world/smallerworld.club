# typed: strict
# frozen_string_literal: true

module Reportable
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  abstract!
  requires_ancestor { ActiveRecord::Base }

  # == Type Aliases ==

  included do
    T.bind(self, T.class_of(ActiveRecord::Base))

    # == Associations ==

    has_many :reports, as: :reportable, dependent: :destroy
  end

  sig { overridable.params(report: Report).void }
  def after_reported(report); end
end
