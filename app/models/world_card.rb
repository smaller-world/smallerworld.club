# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_cards
#
#  id            :uuid             not null, primary key
#  discarded_at  :timestamptz
#  relevant_date :timestamptz
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cardholder_id :uuid
#  device_id     :uuid
#  world_id      :uuid             not null
#  world_key_id  :uuid
#
# Indexes
#
#  index_world_cards_on_cardholder_id  (cardholder_id)
#  index_world_cards_on_device_id      (device_id)
#  index_world_cards_on_discarded_at   (discarded_at)
#  index_world_cards_on_relevant_date  (relevant_date)
#  index_world_cards_on_world_id       (world_id)
#  index_world_cards_on_world_key_id   (world_key_id)
#
# Foreign Keys
#
#  fk_rails_...  (cardholder_id => users.id)
#  fk_rails_...  (device_id => devices.id)
#  fk_rails_...  (world_id => worlds.id)
#  fk_rails_...  (world_key_id => world_keys.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WorldCard < ApplicationRecord
  include Discard::Model

  # == Configuration ==

  RELEVANT_DATE_EXPIRES_IN = T.let(12.hours, ActiveSupport::Duration)

  # == Attributes ==

  attribute :relevant_date, default: -> { Time.current }

  sig { returns(String) }
  def short_id
    ShortUUID.shorten(id)
  end

  sig { params(short_id: String).returns(WorldCard) }
  def self.find_by_short_id!(short_id)
    WorldCard.find(ShortUUID.expand(short_id))
  end

  # == Associations ==

  belongs_to :world
  belongs_to :device, optional: true
  belongs_to :cardholder, class_name: "User", optional: true
end
