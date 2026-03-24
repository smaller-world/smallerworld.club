# typed: true
# frozen_string_literal: true

require "rails"
require "httparty"

class Luma
  extend T::Sig

  include HTTParty

  # == Models ==

  class Event < T::Struct
    const :api_id, String
    const :name, String
    const :description, String
    const :description_md, String
    const :start_at, ActiveSupport::TimeWithZone
    const :end_at, ActiveSupport::TimeWithZone
    const :timezone, String
    const :geo_address_json, T.nilable(T::Hash[String, T.untyped])
    const :geo_latitude, T.nilable(String)
    const :geo_longitude, T.nilable(String)
    const :url, String
  end

  class Tag < T::Struct
    const :id, String
    const :name, String
  end

  class EventEntry < T::Struct
    const :event, Event
    const :tags, T::Array[Tag]
  end

  class ListEventsResponse < T::Struct
    const :entries, T::Array[EventEntry]
    const :has_more, T::Boolean
    const :next_cursor, T.nilable(String)
  end

  # == Exceptions ==

  class Error < StandardError; end

  class BadResponse < StandardError
    extend T::Sig

    sig { params(response: HTTParty::Response).void }
    def initialize(response)
      @response = response
      super("Luma API error (status #{response.code}): #{response.parsed_response}")
    end

    sig { returns(HTTParty::Response) }
    attr_reader :response
  end

  class TooManyRequests < BadResponse; end

  # == Configuration ==

  base_uri "https://public-api.luma.com"
  format :json
  logger Rails.logger, Rails.configuration.log_level

  sig { params(api_key: String).void }
  def initialize(api_key:)
    self.class.headers("x-luma-api-key" => api_key)
  end

  # == Methods ==

  sig do
    params(
      after: T.nilable(ActiveSupport::TimeWithZone),
      before: T.nilable(ActiveSupport::TimeWithZone),
      pagination_cursor: T.nilable(String),
      pagination_limit: T.nilable(Integer),
      sort_column: T.nilable(String),
      sort_direction: T.nilable(String),
    ).returns(ListEventsResponse)
  end
  def list_events(
    after: nil,
    before: nil,
    pagination_cursor: nil,
    pagination_limit: nil,
    sort_column: nil,
    sort_direction: nil
  )
    query = {
      after: after&.iso8601,
      before: before&.iso8601,
      pagination_cursor:,
      pagination_limit:,
      sort_column:,
      sort_direction:,
    }.compact
    response = get!("/v1/calendar/list-events", query:)
    entries = response.fetch("entries").map do |entry|
      event = entry.fetch("event")
      event = Event.new(
        api_id: event.fetch("api_id"),
        name: event.fetch("name"),
        description: event.fetch("description"),
        description_md: event.fetch("description_md"),
        start_at: Time.zone.parse(event.fetch("start_at")),
        end_at: Time.zone.parse(event.fetch("end_at")),
        timezone: event.fetch("timezone"),
        geo_address_json: event.fetch("geo_address_json"),
        geo_latitude: event.fetch("geo_latitude"),
        geo_longitude: event.fetch("geo_longitude"),
        url: event.fetch("url"),
      )
      EventEntry.new(
        event:,
        tags: entry.fetch("tags").map do |tag|
          Tag.new(
            id: tag.fetch("id"),
            name: tag.fetch("name"),
          )
        end,
      )
    end
    ListEventsResponse.new(
      entries:,
      has_more: response.fetch("has_more"),
      next_cursor: response["next_cursor"],
    )
  end

  private

  # == Helpers ==

  sig { params(path: String, options: T.untyped).returns(T.untyped) }
  def get!(path, **options)
    response = self.class.get(path, **options)
    check_response!(response)
    response.parsed_response
  end

  sig { params(response: HTTParty::Response).void }
  def check_response!(response)
    unless response.success?
      case response.code
      when 429
        raise TooManyRequests, response
      else
        raise BadResponse, response
      end
    end
  end
end
