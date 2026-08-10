# typed: strict
# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  # == Actions ==

  sig { params(report: Report).void }
  def created(report:)
    render_email(
      Views::Mailers::Reports::Created.new(report:),
      subject: "new #{report.category.text} report",
      to: SmallerWorld.application.support_email,
    )
  end
end
