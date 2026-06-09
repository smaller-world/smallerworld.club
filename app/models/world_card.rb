# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_cards
#
#  id                :uuid             not null, primary key
#  granted_key_color :string           not null
#  relevant_date     :timestamptz
#  revoked_at        :timestamptz
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  cardholder_id     :uuid
#  device_id         :uuid
#  world_id          :uuid             not null
#
# Indexes
#
#  index_world_cards_on_cardholder_id  (cardholder_id)
#  index_world_cards_on_device_id      (device_id)
#  index_world_cards_on_relevant_date  (relevant_date)
#  index_world_cards_on_revoked_at     (revoked_at)
#  index_world_cards_on_world_id       (world_id)
#
# Foreign Keys
#
#  fk_rails_...  (cardholder_id => users.id)
#  fk_rails_...  (device_id => devices.id)
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WorldCard < ApplicationRecord
  # == Configuration ==

  RELEVANT_DATE_EXPIRES_IN = T.let(12.hours, ActiveSupport::Duration)

  # == Attributes ==

  attribute :relevant_date, default: -> { Time.current }
  enumerize :granted_key_color, in: WorldKey.color.values

  sig { returns(T::Boolean) }
  def revoked? = revoked_at?

  sig { returns(T::Boolean) }
  def active?
    !revoked? && pass_registrations.any?
  end

  sig { returns(T::Boolean) }
  def unclaimed?
    !cardholder_id?
  end

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

  # == Validations ==

  before_validation :set_cardholder_id,
    if: [ :device_id?, :device_id_changed? ],
    unless: :cardholder_id?
  validates :device, presence: true, if: :cardholder_id?

  # == Scopes ==

  scope :active, -> { unrevoked.where.associated(:pass_registrations) }
  scope :unrevoked, -> { where(revoked_at: nil) }
  scope :revoked, -> { where.not(revoked_at: nil) }
  scope :claimed, -> { where.not(cardholder_id: nil) }
  scope :unclaimed, -> { where(cardholder_id: nil) }
  scope :with_expired_relevant_date, -> {
    where(relevant_date: ..(Time.current - RELEVANT_DATE_EXPIRES_IN))
  }
  scope :with_pass_serial_numbers, ->(serial_numbers) {
    joins(:pass).where(passkit_passes: { serial_number: serial_numbers })
  }

  # == Hooks ==

  after_update_commit :trigger_pass_update_later, unless: :revoked_prior_to_last_save?

  # == Passkit ==

  sig { returns(Passkit::Pass) }
  def pass!
    pass || create_pass!(klass: Passkit::WorldCardPass.name, generator: self)
  end

  sig { returns(Passkit::Generator) }
  def passkit_generator
    Passkit::Generator.new(pass!)
  end

  # Push a silent notification to every device that has registered this card's pass.
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

  # == Methods ==

  sig { returns(TrueClass) }
  def revoke!
    update!(revoked_at: Time.current)
  end

  sig { returns(TrueClass) }
  def release!
    update!(cardholder: nil, device: nil)
  end

  sig { returns(TrueClass) }
  def clear_relevant_date!
    update!(relevant_date: nil)
  end

  sig { params(world: World, cardholder: User).returns(T.untyped) }
  def self.revoke_for!(world:, cardholder:)
    transaction do
      world.cards.active.where(cardholder:).find_each(&:revoke!)
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def revoked_prior_to_last_save?
    revoked? && !saved_change_to_revoked_at?
  end

  # == Callbacks ==

  sig { void }
  def set_cardholder_id
    if (device = self.device)
      self.cardholder_id = device.owner_id
    end
  end
end
