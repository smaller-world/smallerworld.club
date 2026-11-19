# typed: true
# frozen_string_literal: true

require "test_helper"

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: reports
#
#  id              :uuid             not null, primary key
#  category        :string           not null
#  note            :text
#  reportable_type :string           not null
#  resolution      :string
#  resolved_at     :timestamptz
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  moderator_id    :uuid
#  reportable_id   :uuid             not null
#  reporter_id     :uuid             not null
#
# Indexes
#
#  index_reports_on_moderator_id  (moderator_id)
#  index_reports_on_reportable    (reportable_type,reportable_id)
#  index_reports_on_reporter_id   (reporter_id)
#  index_reports_on_resolution    (resolution)
#  index_reports_on_resolved_at   (resolved_at)
#
# Foreign Keys
#
#  fk_rails_...  (moderator_id => users.id)
#  fk_rails_...  (reporter_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class ReportTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @owner = users(:bob)
    @reporter = users(:sue)
    @admin = users(:jane)
    @world = create_world(owner: @owner)
    @post = create_post(world: @world)
  end

  test "an unresolved report suppresses its reportable" do
    report = build_report
    assert_includes Report.not_dismissed, report
  end

  test "an upheld report suppresses its reportable" do
    report = build_report
    with_admins(@admin) do
      report.resolve!(resolution: "upheld", moderator: @admin)
    end
    assert_includes Report.not_dismissed, report
  end

  test "a dismissed report does not suppress its reportable" do
    report = build_report
    report.resolve!(resolution: "dismissed", moderator: @admin)
    assert_not_includes Report.not_dismissed, report
  end

  test "resolving records the resolution, moderator and timestamp" do
    report = build_report
    report.resolve!(resolution: "upheld", moderator: @admin)

    assert_equal "upheld", report.resolution
    assert_equal @admin, report.moderator
    assert_not_nil report.resolved_at
  end

  test "an unknown resolution is rejected" do
    report = build_report
    report.resolution = "banished"
    assert_not report.valid?
    assert_includes report.errors.attribute_names, :resolution
  end

  test "creating a report emails support" do
    report = T.let(nil, T.nilable(Report))
    emails = capture_emails { report = build_report }

    assert_equal 1, emails.size
    email = emails.fetch(0)
    assert_equal [ SmallerWorld.application.support_email_address ], email.to

    links = Nokogiri::HTML((email.html_part || email).body.decoded).css("a")
    review_link = links.find { |link| link.text.strip == "review this report" }
    expected_url = Rails.application.routes.url_helpers.admin_report_url(
      report, **ApplicationMailer.default_url_options
    )
    assert_equal expected_url, review_link&.attr("href")
  end

  private

  def build_report
    @post.reports.create!(reporter: @reporter, category: "spam")
  end
end
