# typed: strict
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

  # == Scopes ==

  scope :unlinked, -> { where(cardholder_id: nil) }

  # == Hooks ==

  after_save :create_granted_key,
    if: [ :cardholder_id?, :cardholder_id_previously_changed? ]
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

  private

  # == Callbacks ==

  sig { void }
  def create_granted_key
    world!.keys.find_or_create_by!(
      color: granted_key_color,
      recipient: cardholder,
      accepted_at: Time.current,
    )
  end
end
