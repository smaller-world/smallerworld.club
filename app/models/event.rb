# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: events
#
#  id             :uuid             not null, primary key
#  description    :text             not null
#  description_md :text             not null
#  duration       :tstzrange        not null
#  geo_address    :jsonb
#  geo_location   :geography        point, 4326
#  luma_url       :string           not null
#  name           :string           not null
#  tag_ids        :string           default([]), not null, is an Array
#  time_zone_name :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  luma_id        :string           not null
#
# Indexes
#
#  index_events_on_luma_id  (luma_id) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Event < ApplicationRecord
  # == Attributes ==

  sig { returns(RGeo::Geographic::Factory) }
  def self.geo_location_factory
    RGeo::Geographic.spherical_factory(srid: 4326)
  end

  sig { returns(ActiveSupport::TimeZone) }
  def time_zone
    ActiveSupport::TimeZone.new(time_zone_name)
  end

  sig { returns(T::Range[ActiveSupport::TimeWithZone]) }
  def duration
    start_at..end_at
  end

  sig { returns(ActiveSupport::TimeWithZone) }
  def start_at
    self[:duration].begin.in_time_zone(time_zone)
  end

  sig { returns(ActiveSupport::TimeWithZone) }
  def end_at
    self[:duration].end.in_time_zone(time_zone)
  end

  # == Importing ==

  sig { returns(T::Array[Event]) }
  def self.import_from_luma
    client = Luma.new(api_key: Rails.application.credentials.luma.api_key)
    cursor = T.let(nil, T.nilable(String))
    events = T.let([], T::Array[Event])

    loop do
      response = client.list_events(
        sort_column: "start_at",
        sort_direction: "desc nulls last",
        pagination_cursor: cursor,
      )
      response.entries.each do |entry|
        # Stop at undated or past events (sorted desc, so once we hit a past
        # event, all remaining are past too)
        break if entry.event.start_at < Time.zone.now

        events << upsert_from_luma_entry(entry)
      end

      break unless response.has_more

      cursor = response.next_cursor
    end

    events
  end

  # == Helpers ==

  # sig { params(only: T.nilable(T::Array[Symbol])).returns(T.nilable(Event)) }
  # def self.next_fairgrounds_event(only: nil)
  #   next_event_for_tag_id(
  #     Rails.configuration.x.fairgrounds_tag_id,
  #     only:,
  #   )
  # end

  # sig { params(only: T.nilable(T::Array[Symbol])).returns(T.nilable(Event)) }
  # def self.next_mindful_miles_event(only: nil)
  #   next_event_for_tag_id(
  #     Rails.configuration.x.mindful_miles_tag_id,
  #     only:,
  #   )
  # end

  sig { params(tag_id: String, only: T.nilable(T::Array[Symbol])).returns(T.nilable(Event)) }
  def self.next_event_for_tag_id(tag_id, only: nil)
    time_zone = time_zone_for_tag_id(tag_id) or return
    day_start = time_zone.now.beginning_of_day
    relation = where("? = ANY(tag_ids)", tag_id)
      .where("LOWER(duration) >= ?", day_start)
      .where("LOWER(duration) < ?", day_start + 1.week)
      .order(Arel.sql("LOWER(duration) ASC"))
    if only
      relation = T.cast(relation.select(*T.unsafe(only)), PrivateRelation)
    end
    relation.first
  end

  private

  # == Helpers ==

  sig { params(entry: Luma::EventEntry).returns(Event) }
  private_class_method def self.upsert_from_luma_entry(entry)
    find_or_initialize_by(luma_id: entry.event.api_id).tap do |event|
      geo_location = if (latitude = entry.event.geo_latitude) &&
          (longitude = entry.event.geo_longitude)
        geo_location_factory.point(longitude, latitude)
      end
      event.update!(
        name: entry.event.name,
        description: entry.event.description,
        description_md: entry.event.description_md,
        duration: entry.event.start_at..entry.event.end_at,
        time_zone_name: entry.event.timezone,
        geo_address: entry.event.geo_address_json,
        geo_location:,
        luma_url: entry.event.url,
        tag_ids: entry.tags.map(&:id),
      )
    end
  end

  sig { params(tag_id: String).returns(T.nilable(ActiveSupport::TimeZone)) }
  private_class_method def self.time_zone_for_tag_id(tag_id)
    name = where("LOWER(duration) >= NOW()")
      .where("? = ANY(tag_ids)", tag_id)
      .order(Arel.sql("LOWER(duration) ASC"))
      .pick(:time_zone_name) or return
    ActiveSupport::TimeZone.new(name)
  end
end
