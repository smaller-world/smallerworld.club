# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id                                 :uuid             not null, primary key
#  app_last_visited_at                :timestamptz
#  email_address                      :string
#  email_address_confirmation_sent_at :timestamptz
#  email_address_confirmed_at         :timestamptz
#  has_v1_account                     :boolean          default(FALSE), not null
#  name                               :string           not null
#  phone_number                       :string           not null
#  time_zone_name                     :string           not null
#  unconfirmed_email_address          :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
# Indexes
#
#  index_users_on_email_addresses_case_insensitive  (lower((email_address)::text)) UNIQUE WHERE (email_address IS NOT NULL)
#  index_users_on_phone_number                      (phone_number) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:bob) # phone_number +14165558323
  end

  test "world invitations include account and phone matches without duplicates" do
    world = create_world(owner: users(:sue))
    direct = world.invitations.create!(recipient: @user, granted_post_type_ids: world.post_type_ids)
    phone_world = create_world(owner: users(:sue), name: "another world")
    phone_only = phone_world.invitations.create!(recipient_phone_number: @user.phone_number,
      granted_post_type_ids: phone_world.post_type_ids)
    unrelated = world.invitations.create!(recipient_phone_number: "+14165550101",
      granted_post_type_ids: world.post_type_ids)

    assert_equal [ direct.id ], @user.received_world_invitations.pluck(:id)
    assert_equal [ direct.id, phone_only.id ].sort, @user.world_invitations.pluck(:id).sort
    assert_not_includes @user.world_invitations, unrelated
  end

  test "deleting a recipient preserves invitations and clears their account reference" do
    recipient = User.create!(name: "Alex", phone_number: "+14165550101",
      email_address: "alex@example.com", time_zone_name: "America/Toronto")
    world = create_world(owner: users(:sue))
    invitation = world.invitations.create!(recipient:, granted_post_type_ids: world.post_type_ids)

    assert_no_difference "WorldInvitation.count" do
      recipient.destroy!
    end

    assert_nil invitation.reload.recipient_id
    assert_equal recipient.phone_number, invitation.recipient_phone_number
    assert_equal world.post_type_ids.sort, invitation.granted_post_type_ids.sort
    assert_predicate invitation, :persisted?
  end

  test "disabled v1 checks preserve user creation, validation, and other callbacks" do
    assert_predicate User, :v1_checks_disabled?
    V1::User.stub(:exists?, ->(**) { flunk "unexpected v1 lookup" }) do
      user = User.new(
        name: " Alex ",
        phone_number: "+14165550101",
        email_address: "alex@example.com",
        time_zone_name: "America/Toronto"
      )
      assert user.save!
      assert_not user.reload.has_v1_account?
      assert_equal "Alex", user.name

      user.name = ""
      assert_not user.valid?
      assert user.errors.added?(:name, :blank)
    end
  end

  test "enabled v1 checks look up the account during creation" do
    config = SmallerWorld.application.config.x
    previous = config.v1_checks_disabled
    config.v1_checks_disabled = false
    assert_not User.v1_checks_disabled?
    lookups = []
    V1::User.stub(:exists?, ->(**attributes) {
      lookups << attributes
      true
    }) do
      user = User.create!(name: "Alex", phone_number: "+14165550101",
        email_address: "alex@example.com", time_zone_name: "America/Toronto")
      assert_predicate user.reload, :has_v1_account?
      assert_equal [ { phone_number: user.phone_number } ], lookups
    end
  ensure
    config.v1_checks_disabled = previous
  end

  test "record_app_visit! saves the visit and enqueues a badge update with pending notifications" do
    freeze_time do
      @user.update!(app_last_visited_at: 1.minute.ago)
      post = create_post(world: create_world(owner: users(:sue)), quiet: true)
      post.notifications.create!(recipient: @user)

      assert_enqueued_with(job: ClearUserBadgeCountsJob, args: [ @user ]) do
        assert @user.record_app_visit!
      end
      assert_equal Time.current, @user.reload.app_last_visited_at
    end
  end

  test "record_app_visit! saves the visit without a badge update when there are no notifications" do
    freeze_time do
      assert_no_enqueued_jobs(only: ClearUserBadgeCountsJob) do
        assert @user.record_app_visit!
      end
      assert_equal Time.current, @user.reload.app_last_visited_at
    end
  end

  test "record_app_visit! skips the badge update for notifications from before the previous visit" do
    freeze_time do
      @user.update!(app_last_visited_at: 1.minute.ago)
      post = create_post(world: create_world(owner: users(:sue)), quiet: true)
      post.notifications.create!(recipient: @user, created_at: 2.minutes.ago)

      assert_no_enqueued_jobs(only: ClearUserBadgeCountsJob) do
        assert @user.record_app_visit!
      end
      assert_equal Time.current, @user.reload.app_last_visited_at
    end
  end

  test "dm_url builds an sms link" do
    url = @user.dm_url(platform: :sms, message: "hi there")

    assert_equal "sms:#{@user.phone_number}?body=hi%20there", url
  end

  test "dm_url builds a whatsapp link" do
    url = @user.dm_url(platform: :whatsapp, message: "hi there")

    assert_equal "https://wa.me/#{@user.phone_number}?text=hi%20there", url
  end

  test "dm_url builds a telegram link" do
    url = @user.dm_url(platform: :telegram, message: "hi there")

    assert_equal "https://t.me/#{@user.phone_number}?text=hi%20there", url
  end
end
