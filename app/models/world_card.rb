# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_cards
#
#  id                     :uuid             not null, primary key
#  granted_key_color      :string           not null
#  granted_key_created_at :timestamptz
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  device_id              :uuid
#  world_id               :uuid             not null
#
# Indexes
#
#  index_world_cards_on_device_id  (device_id)
#  index_world_cards_on_world_id   (world_id)
#
# Foreign Keys
#
#  fk_rails_...  (device_id => devices.id)
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WorldCard < ApplicationRecord
  # == Attributes ==

  enumerize :granted_key_color, in: WorldKey.color.values

  sig { returns(T::Boolean) }
  def granted_key_created? = granted_key_created_at?

  # == Associations ==

  belongs_to :world

  belongs_to :device, optional: true
  has_one :cardholder, through: :device, source: :owner

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

  # == Scopes ==

  scope :unlinked, -> { where(device_id: nil) }
  scope :pending_granted_key_creation, -> { where(granted_key_created_at: nil) }

  # == Hooks ==

  after_save :create_granted_key!,
    if: [ :device_id?, :device_id_previously_changed? ],
    unless: :granted_key_created?
  after_commit :trigger_pass_update_later, on: :update

  # == Methods ==

  sig { returns(Passkit::Pass) }
  def pass!
    pass || create_pass!(klass: Passes::WorldCard.name, generator: self)
  end

  sig { returns(Passkit::Generator) }
  def passkit_generator
    Passkit::Generator.new(pass!)
  end

  # == Callbacks ==

  sig { void }
  def create_granted_key!
    if (cardholder = self.cardholder)
      cardholder.world_keys.find_or_create_by!(
        world_id:,
        color: granted_key_color,
      ) do |key|
        key.accepted_at = Time.current
      end
      update!(granted_key_created_at: Time.current)
    end
  end

  # == Pass Updates ==

  # Push a silent notification to every device that has registered this
  # card's pass. On per-device APNs token errors, prune the registration
  # (and the device, if it now has no remaining registrations) so we stop
  # pinging dead tokens — per Apple's "prune devices that fail APNs
  # delivery" guidance.
  sig { void }
  def trigger_pass_update
    pass_devices.find_each do |device|
      notification = PasskitPushNotification.silent.new
      notification.token = device.push_token
      begin
        ActionPushNative.service_for(:apple, notification).push(notification)
        tag_logger do
          Rails.logger.info("Pushed pass update to passkit device #{device.id}")
        end
      rescue ActionPushNative::TokenError
        device.destroy!
      end
    end
  end

  # Enqueue the silent APNs push that tells Apple Wallet to re-download this
  # card's `.pkpass`. Wired to `after_commit on: :update` (fires on touches
  # too, which is how `World#touch_cards` propagates name/icon changes).
  sig { void }
  def trigger_pass_update_later
    TriggerWorldCardPassUpdateJob.perform_later(self)
  end
end
