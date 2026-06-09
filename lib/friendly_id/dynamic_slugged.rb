# typed: strict
# frozen_string_literal: true

require "friendly_id"
require "shortuuid"

# A FriendlyId addon that generates slugs on the fly from a "base" column
# value combined with the record's primary key, without persisting a slug.
#
# Slugs have the form `"<parameterized-base>-<id-with-dashes-stripped>"`.
# Finders parse the trailing id off the slug and look up by primary key, so
# the base value is free to change without breaking URLs.
#
# Example:
#
#     class World < ApplicationRecord
#       extend FriendlyId
#       friendly_id :name, use: FriendlyId::DynamicSlugged
#     end
#
#     world = World.create!(name: "Bob's Sandwich")
#     world.friendly_id            # => "bobs-sandwich-9f3a...c1"
#     World.friendly.find(world.friendly_id) == world  # => true
module FriendlyId::DynamicSlugged
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActiveRecord::Base }
  requires_ancestor { FriendlyId::Model }

  sig { params(model_class: T.all(T::Class[ActiveRecord::Base], FriendlyId::Base)).void }
  def self.included(model_class)
    model_class.friendly_id_config.instance_eval do
      self.class.send(:include, Configuration)
      self.finder_methods = FinderMethods
      defaults[:sequence_separator] ||= "-"
      defaults[:slug_limit] ||= 32
    end
  end

  # Generate the friendly id on demand from the configured base column and
  # the record's primary key.
  sig { returns(T.nilable(String)) }
  def friendly_id
    record = T.cast(self, ActiveRecord::Base)
    base_value = public_send(friendly_id_config.base)
    id_value = public_send(record.class.primary_key)
    return if base_value.blank? || id_value.blank?

    slug = normalize_friendly_id(base_value)
    tail = ShortUUID.shorten(id_value)
    [ slug.presence, tail ].compact.join(friendly_id_config.sequence_separator)
  end

  # Process the base value into the leading portion of the slug. Override in
  # the model for custom formatting.
  sig { params(value: T.untyped).returns(String) }
  def normalize_friendly_id(value)
    string = value.to_s
    if (limit = friendly_id_config.slug_limit)
      string = string[0, limit].to_s
    end
    string.strip.parameterize
  end

  # Adds `:sequence_separator` and `:slug_limit` options to
  # {FriendlyId::Configuration} and points lookups at the primary key.
  module Configuration
    extend T::Sig
    extend T::Helpers

    requires_ancestor { FriendlyId::Configuration }

    # == Attributes ==

    sig { params(sequence_separator: T.nilable(String)).returns(T.nilable(String)) }
    attr_writer :sequence_separator

    sig { params(slug_limit: T.nilable(Integer)).returns(T.nilable(Integer)) }
    attr_writer :slug_limit

    # Look up records by the primary key — `FinderMethods#parse_friendly_id`
    # extracts the id from the slug's tail.
    sig { returns(String) }
    def query_field
      model_class.primary_key
    end

    sig { returns(String) }
    def sequence_separator
      @sequence_separator ||= defaults[:sequence_separator]
    end

    sig { returns(Integer) }
    def slug_limit
      @slug_limit ||= defaults[:slug_limit]
    end
  end

  # Custom finders that extract the trailing primary key from a dynamic slug.
  module FinderMethods
    extend T::Sig

    include FriendlyId::FinderMethods

    private

    sig { params(value: T.untyped).returns(String) }
    def parse_friendly_id(value)
      string = value.to_s
      tail = string.split("-").last
      if tail.present?
        ShortUUID.expand(tail)
      else
        string
      end
    end
  end
end
