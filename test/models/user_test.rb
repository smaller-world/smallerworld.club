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
