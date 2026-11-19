# typed: strict
# frozen_string_literal: true

require "test_helper"

class WellKnownControllerTest < ActionDispatch::IntegrationTest
  test "serves the apple-app-site-association file" do
    get apple_app_site_association_path
    assert_response :success
    assert_equal "application/json", response.content_type

    app_id = "UB3SB3746X.club.smallerworld.ios"
    details = response.parsed_body.fetch("applinks").fetch("details")
    association = details.find { |entry| entry.fetch("appIDs", []).include?(app_id) }
    assert association, "expected an association for #{app_id}"

    components = association.fetch("components")
    catch_all = components.find { |rule| rule["/"] == "/*" }
    assert catch_all, "expected a catch-all for other paths"
    refute catch_all["exclude"], "expected the catch-all to open the app"

    excluded_paths = components.take_while { |rule| rule["/"] != "/*" }.filter_map do |rule|
      rule["/"] if rule["exclude"] == true
    end
    assert_empty %w[/ /install /policies /support /contact] - excluded_paths
  end
end
