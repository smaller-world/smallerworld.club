# typed: true
# frozen_string_literal: true

require "test_helper"
require_relative "../../db/seeds/development"

class DevelopmentDataTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  # Exercise real commits so suppression is checked against after_commit hooks.
  self.use_transactional_tests = false

  teardown do
    Notification.suppress do
      Post.suppressing_turbo_broadcasts do
        WorldKey.suppressing_turbo_broadcasts do
          World.where(owner_id: DevelopmentData::USER_NAMES.map { |name| DevelopmentData.id("user/#{name}") }).destroy_all
          User.where(id: DevelopmentData::USER_NAMES.map { |name| DevelopmentData.id("user/#{name}") }).destroy_all
        end
      end
    end
  end

  test "baseline is repeatable, preserves edits, and suppresses only seed delivery" do
    config = SmallerWorld.application.config.x
    previous = config.v1_checks_disabled
    config.v1_checks_disabled = false
    V1::User.stub(:exists?, ->(**) { flunk "unexpected legacy lookup" }) do
      ActionCable.server.stub(:broadcast, ->(*_args) { flunk "unexpected seed broadcast" }) do
        assert_no_enqueued_jobs(except: [ ActiveStorage::AnalyzeJob, ActiveStorage::TransformJob ]) do
          assert_enqueued_with(job: ActiveStorage::AnalyzeJob) { DevelopmentData.seed! }
        end
      end
    end
    assert_not User.v1_checks_disabled?
    assert_not Post.suppressed_turbo_broadcasts?
    assert_not WorldKey.suppressed_turbo_broadcasts?

    users = DevelopmentData::USER_NAMES.to_h { |name| [ name.to_sym, User.find(DevelopmentData.id("user/#{name}")) ] }
    worlds = DevelopmentData::POST_COUNTS.keys.index_with { |name| World.find(DevelopmentData.id("world/#{name}")) }
    users.each_value do |user|
      assert_not user.has_v1_account?
      assert user.email_address_confirmed_at
      assert user.email_address.to_s.end_with?("@example.com")
    end
    DevelopmentData::POST_COUNTS.each do |name, count|
      assert_equal count, worlds.fetch(name).posts.count
    end
    assert_equal 2, users.fetch(:casey).owned_worlds.count
    assert_empty worlds.fetch(:alex).keys
    assert_equal %i[alex casey drew ellis].map { |name| users.fetch(name).id }.sort,
      worlds.fetch(:blair).keys.pluck(:recipient_id).sort
    {
      alex: [], blair: %i[alex casey drew ellis], casey: %i[alex blair],
      drew: %i[casey], ellis: %i[blair drew],
    }.each do |owner, recipients|
      assert_equal recipients.map { |name| users.fetch(name).id }.sort,
        worlds.fetch(owner).keys.pluck(:recipient_id).sort
    end
    field_note = worlds.fetch(:casey).post_types.find_by!(label: "field note")
    assert_equal [ users.fetch(:blair).id ], field_note.recipients.pluck(:id)
    assert_equal 2, WorldInvitation.where(world: worlds.values).pending_acceptance.count
    assert_equal 0, Device.where(owner: users.values).count
    assert_equal 0, PhoneNumberVerificationRequest.where(phone_number: users.values.map(&:phone_number)).count

    blair = worlds.fetch(:blair)
    excluded = blair.posts.find(DevelopmentData.id("post/blair/1"))
    assert_not excluded.visible_to?(users.fetch(:drew))
    assert excluded.visible_to?(users.fetch(:casey))
    assert_predicate excluded, :favorited?
    assert_equal [ "journal entry" ], blair.keys.find_by!(recipient: users.fetch(:alex)).granted_post_types.pluck(:label)
    assert_equal [ blair.post_types.find_by!(label: "poem").id ], blair.keys.find_by!(recipient: users.fetch(:ellis)).muted_post_type_ids
    assert_empty worlds.fetch(:ellis).keys.find_by!(recipient: users.fetch(:blair)).new_visible_world_posts_since_last_visited
    assert_predicate worlds.fetch(:casey).keys.find_by!(recipient: users.fetch(:alex)).new_visible_world_posts_since_last_visited, :exists?

    notifications = Notification.where(recipient: users.values)
    assert_equal 4, notifications.count
    assert notifications.all?(&:delivered?)
    assert_equal 1, notifications.where.not(received_at: nil).count

    users.fetch(:alex).update!(name: "my local name")
    blair.update!(name: "my local world")
    blair.post_types.find_by!(label: "journal entry").update!(label: "my local type")
    excluded.update!(title: "my local post")
    missing = blair.posts.find(DevelopmentData.id("post/blair/2"))
    Post.suppressing_turbo_broadcasts { missing.destroy! }
    counts = [ User.count, World.count, WorldKey.count, Notification.count ]
    assert_no_enqueued_jobs(except: [ ActiveStorage::AnalyzeJob, ActiveStorage::TransformJob ]) do
      ActionCable.server.stub(:broadcast, ->(*_args) { flunk "unexpected seed broadcast" }) do
        DevelopmentData.seed!
        DevelopmentData.seed!
      end
    end
    assert_equal counts, [ User.count, World.count, WorldKey.count, Notification.count ]
    assert_equal 60, blair.posts.count
    assert_equal "my local name", users.fetch(:alex).reload.name
    assert_equal "my local world", blair.reload.name
    assert_equal "my local type", blair.post_types.find(DevelopmentData.id("type/blair/journal entry")).label
    assert_equal "my local post", excluded.reload.title

    assert_enqueued_with(job: DeliverNotificationJob) do
      excluded.notifications.create!(recipient: users.fetch(:casey))
    end
  ensure
    config.v1_checks_disabled = previous if config
  end

  test "setup restores missing default types and preserves existing type edits" do
    DevelopmentData.seed!
    %w[alex blair casey_second].each do |label|
      world = World.find(DevelopmentData.id("world/#{label}"))
      world.post_types.find(DevelopmentData.id("type/#{label}/poem")).destroy!
      world.post_types.find(DevelopmentData.id("type/#{label}/journal entry")).update!(label: "local label", icon: "huge/book-edit")
    end

    2.times { DevelopmentData.seed! }

    %w[alex blair casey_second].each do |label|
      world = World.find(DevelopmentData.id("world/#{label}"))
      restored = world.post_types.find(DevelopmentData.id("type/#{label}/poem"))
      assert_equal "poem", restored.label
      assert_equal World.default_post_types.find { |type| type.label == "poem" }&.icon, restored.icon
      edited = world.post_types.find(DevelopmentData.id("type/#{label}/journal entry"))
      assert_equal "local label", edited.label
      assert_equal "huge/book-edit", edited.icon
      assert_equal World.default_post_types.size, world.post_types.count
    end
  end

  test "failed seed creation restores the v1 flag and suppression" do
    notification = T.let(nil, T.nilable(Notification))
    config = SmallerWorld.application.config.x
    previous = config.v1_checks_disabled
    config.v1_checks_disabled = false
    DevelopmentData.stub(:create_users, -> { raise "seed failed" }) do
      assert_raises(RuntimeError) { DevelopmentData.seed! }
    end
    assert_not User.v1_checks_disabled?
    assert_not Post.suppressed_turbo_broadcasts?
    assert_not WorldKey.suppressed_turbo_broadcasts?
    assert_enqueued_with(job: DeliverNotificationJob) do
      notification = Notification.create!(noticeable: users(:sue), recipient: users(:bob))
    end
  ensure
    notification&.destroy!
    config.v1_checks_disabled = previous if config
  end
end
