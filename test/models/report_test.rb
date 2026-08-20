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

  test "resolving is idempotent and can reverse a decision" do
    report = build_report
    report.resolve!(resolution: "upheld", moderator: @admin)
    report.resolve!(resolution: "dismissed", moderator: @admin)

    assert_equal "dismissed", report.reload.resolution
    assert_not_includes Report.not_dismissed, report
  end

  test "an unknown resolution is rejected" do
    report = build_report
    report.resolution = "banished"
    assert_not report.valid?
    assert_includes report.errors.attribute_names, :resolution
  end

  test "creating a report emails support" do
    assert_enqueued_emails 1 do
      build_report
    end
  end

  private

  def build_report
    @post.reports.create!(reporter: @reporter, category: "spam")
  end
end
