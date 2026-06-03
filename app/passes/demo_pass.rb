# typed: true
# frozen_string_literal: true

class Passes::DemoPass < Passkit::ExampleStoreCard
  extend T::Sig

  # == Configuration ==

  private def folder_name
    "example_store_card"
  end

  # == Attributes ==

  def relevant_date
    Time.current.iso8601
  end

  def expiration_date
    1.day.from_now.iso8601
  end

  def header_fields
    [ { key: "balance", label: "Balance", value: 100, currencyCode: "USD" } ]
  end

  def app_launch_url
    nil
  end
end
