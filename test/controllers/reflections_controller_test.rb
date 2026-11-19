# typed: true
# frozen_string_literal: true

require "test_helper"

class ReflectionsControllerTest < ActionDispatch::IntegrationTest
  test "an invalid date cannot be edited or updated" do
    sign_in_as(users(:bob))

    get edit_reflection_path("2026-02-30")
    assert_response :not_found

    assert_no_difference -> { Reflection.count } do
      patch reflection_path("2026-02-30"), params: { reflection: { body: "Invalid date" } }
    end
    assert_response :not_found
  end

  test "authors can reopen their own saved reflections for the same date" do
    date = "2026-11-15"
    bob = users(:bob)
    sue = users(:sue)
    sue.reflections.create!(date:, body: "Sue's private reflection")

    sign_in_as(bob)
    put reflection_path(date), params: { reflection: { body: "Bob's private reflection" } }
    assert_redirected_to places_dock_path

    get edit_reflection_path(date)
    assert_response :success
    assert_select "lexxy-editor[name='reflection[body]']", count: 1 do |editors|
      assert_equal "Bob's private reflection", Nokogiri::HTML.fragment(editors.first["value"].to_s).text.strip
    end

    sign_in_as(sue)
    get edit_reflection_path(date)
    assert_response :success
    assert_select "lexxy-editor[name='reflection[body]']", count: 1 do |editors|
      assert_equal "Sue's private reflection", Nokogiri::HTML.fragment(editors.first["value"].to_s).text.strip
    end
  end

  test "the reflections frame requires a valid time zone" do
    sign_in_as(users(:bob))
    headers = { "Turbo-Frame" => "reflections" }

    [ {}, { time_zone_name: "Unknown/Zone" }, { time_zone_name: [ "UTC" ] } ].each do |params|
      get(reflections_path, params:, headers:)
      assert_response :bad_request
    end
  end

  test "the dock shows the author's last seven days in the requested time zone, newest first" do
    travel_to Time.utc(2026, 11, 16, 6) do
      author = users(:bob)
      today = Date.new(2026, 11, 15)
      saved_date = today - 2
      author.reflections.create!(date: saved_date, body: "My reflection")
      author.reflections.create!(date: today - 7, body: "Older reflection")
      author.reflections.create!(date: today + 1, body: "Future reflection")
      users(:sue).reflections.create!(date: today, body: "Another author's reflection")
      sign_in_as(author)

      get reflections_path(time_zone_name: "America/Los_Angeles"), headers: { "Turbo-Frame" => "reflections" }

      assert_response :success
      assert_select "turbo-frame#reflections a.reflection-item", count: 7 do |items|
        dates = today.downto(today - 6).to_a
        assert_equal dates.map { |date| edit_reflection_path(date.iso8601) },
          items.pluck("href")
        assert_equal [ edit_reflection_path(saved_date.iso8601) ],
          items.reject { |item| item.key?("data-new") }.pluck("href")
        assert_includes items[2].text, "My reflection"
      end
      refute_includes response.body, "Another author's reflection"
    end
  end
end
