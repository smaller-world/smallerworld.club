# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class UserReportsTest < ApplicationSystemTestCase
  test "reporting a world owner leaves their worlds and revokes their access" do
    owner = users(:bob)
    reporter = users(:sue)
    world = worlds(:bobs_world_one)
    key = create_member_key(world:, recipient: reporter)
    create_member_key(world: worlds(:bobs_world_two), recipient: reporter)
    create_member_key(world: worlds(:sues_world), recipient: owner)

    sign_in_as(reporter)
    visit world_key_path(key)
    click_link "report #{owner.name} and leave world"

    click_button "please select one"
    find("[role='option']", text: "other", exact_text: true).click
    fill_in "note", with: "this account is harassing me"
    click_button "report and remove account"

    assert_current_path home_path
    assert_text "your report has been submitted and will be reviewed by our team."
    report = owner.reports.find_by!(reporter:)
    assert_equal "other", report.category
    assert_equal "this account is harassing me", report.note
    assert_not WorldKey.exists?(world: owner.owned_worlds, recipient: reporter)
    assert_not WorldKey.exists?(world: reporter.owned_worlds, recipient: owner)
  end
end
