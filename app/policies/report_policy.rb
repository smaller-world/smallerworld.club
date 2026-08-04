# typed: true
# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  # == Rules ==

  def manage?
    report = T.let(record, Report)
    user = user!
    report.reporter_id == user.id
  end
end
