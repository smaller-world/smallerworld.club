# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: devices
#
#  id              :uuid             not null, primary key
#  name            :string
#  platform        :string           not null
#  token           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  installation_id :string           not null
#  owner_id        :uuid             not null
#
# Indexes
#
#  index_devices_on_installation_id  (installation_id) UNIQUE
#  index_devices_on_owner_id         (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Device < ActionPushNative::Device
  extend Enumerize
  extend T::Sig

  # == Configuration ==

  # Customize TokenError handling (default: destroy!)
  # rescue_from (ActionPushNative::TokenError) { Rails.logger.error("Device #{id} token is invalid") }

  # == Attributes ==

  enumerize :platform, in: [ :apple, :google ]

  # == Associations ==

  belongs_to :owner, class_name: "User"

  sig { returns(User) }
  def owner!
    owner or raise ActiveRecord::RecordNotFound, "Missing owner"
  end

  # == Validations ==

  validates :installation_id, uniqueness: true

  # == Methods ==

  # sig { void }
  # def send_test_notification
  #   url_helpers = Rails.application.routes.url_helpers
  #   notification = PushNotification
  #     .with_data(target_url: url_helpers.world_path)
  #     .new(
  #       title: "test notification",
  #       body: "this is a test notification. if you are seeing this, then " \
  #         "your push notifications are working!",
  #     )
  #   notification.deliver_to(self)
  # end
end
