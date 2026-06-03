# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_cards
#
#  id                :uuid             not null, primary key
#  granted_key_color :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cardholder_id     :uuid
#  world_id          :uuid             not null
#
# Indexes
#
#  index_world_cards_on_cardholder_id  (cardholder_id)
#  index_world_cards_on_world_id       (world_id)
#
# Foreign Keys
#
#  fk_rails_...  (cardholder_id => users.id)
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WorldCard < ApplicationRecord
  # == Attributes ==

  enumerize :granted_key_color, in: WorldKey.color.values

  # == Associations ==

  belongs_to :world
  has_many :world_keys, through: :world, source: :keys

  belongs_to :cardholder, class_name: "User", optional: true
  has_one :pass,
    as: :generator,
    class_name: "Passkit::Pass",
    dependent: :destroy
  has_many :pass_registrations,
    class_name: "Passkit::Registration",
    through: :pass,
    source: :registrations
  has_many :pass_devices,
    class_name: "Passkit::Device",
    through: :pass_registrations,
    source: :device

  sig { returns(World) }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  # == Hooks ==

  after_save :create_granted_key,
    if: [ :cardholder_id?, :cardholder_id_previously_changed? ]

  private

  # == Callbacks ==

  sig { void }
  def create_granted_key
    world!.keys.find_or_create_by!(
      color: granted_key_color,
      recipient: cardholder,
    )
  end
end
