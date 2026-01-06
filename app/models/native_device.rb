# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: action_push_native_devices
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
#  index_action_push_native_devices_on_owner_id  (owner_id)
#  index_action_push_native_devices_uniqueness   (installation_id,owner_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class NativeDevice < ActionPushNative::Device
  # == Configuration ==

  # Customize TokenError handling (default: destroy!)
  # rescue_from (ActionPushNative::TokenError) { Rails.logger.error("Device #{id} token is invalid") }

  # == Attributes ==

  enumerize :platform, in: %i[apple google]

  # == Associations ==

  belongs_to :owner, class_name: "User", inverse_of: :native_devices

  sig { returns(User) }
  def owner!
    owner or raise ActiveRecord::RecordNotFound, "Missing owner"
  end

  # == Validations ==

  validates :installation_id, uniqueness: { scope: :owner }

  # == Methods ==

  sig { void }
  def send_test_notification
    url_helpers = Rails.application.routes.url_helpers
    notification = NativeNotification
      .with_data(target_url: url_helpers.settings_path(
        test_notification_success: 1,
      ))
      .new(
        title: "test notification",
        body: "this is a test notification. if you are seeing this, then " \
          "your push notifications are working!",
      )
    notification.deliver_to(self)
  end
end
