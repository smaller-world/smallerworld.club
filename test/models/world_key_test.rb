# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_keys
#
#  id                    :uuid             not null, primary key
#  muted_post_type_ids   :uuid             default([]), not null, is an Array
#  world_last_visited_at :timestamptz
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  invitation_id         :uuid
#  recipient_id          :uuid             not null
#  type_id               :uuid             not null
#  world_id              :uuid             not null
#
# Indexes
#
#  index_world_keys_on_id_and_world_id      (id,world_id) UNIQUE
#  index_world_keys_on_invitation_id        (invitation_id)
#  index_world_keys_on_muted_post_type_ids  (muted_post_type_ids) USING gin
#  index_world_keys_on_recipient_id         (recipient_id)
#  index_world_keys_on_world_id             (world_id)
#  index_world_keys_uniqueness              (world_id,recipient_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  ([invitation_id, world_id] => world_invitations[id, world_id])
#  fk_rails_...  ([world_id, type_id] => world_key_types[world_id, id])
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
require "test_helper"

class WorldKeyTest < ActiveSupport::TestCase
  setup do
    @world = create_world(owner: users(:bob), name: "Key Test World")
    @recipient = users(:sue)
  end

  test "a recipient may hold only one key per world" do
    type = @world.key_types.first!
    @world.keys.create!(recipient: @recipient, type:)
    duplicate = @world.keys.build(recipient: @recipient, type:)

    assert_not_predicate duplicate, :valid?
    assert_includes duplicate.errors, :recipient
  end

  test "the world owner cannot be granted a key" do
    key = @world.keys.build(recipient: users(:bob), type: @world.key_types.first!)

    assert_not_predicate key, :valid?
    assert_includes key.errors, :recipient
  end

  test "rejects a key type from another world" do
    other_world = worlds(:bobs_world_one)
    type = other_world.key_types.create!(name: "close friends", color: "pink")
    key = @world.keys.build(recipient: @recipient, type_id: type.id)

    assert_not_predicate key, :valid?
    assert_equal [ "must belong to this world" ], key.errors[:type]
  end

  test "rejects an unknown key type id" do
    key = @world.keys.build(recipient: @recipient, type_id: SecureRandom.uuid)

    assert_not_predicate key, :valid?
    assert_includes key.errors[:type], "must exist"
  end

  test "orders keys by their latest visible post" do
    older_key = @world.keys.create!(recipient: @recipient, type: @world.key_types.first!)
    create_post(world: @world, visible_to_key_type_ids: [ older_key.type_id ])

    newer_world = create_world(owner: users(:bob), name: "Newer Key Test World")
    newer_key = newer_world.keys.create!(recipient: @recipient, type: newer_world.key_types.first!)
    travel_to 1.minute.from_now do
      create_post(world: newer_world, visible_to_key_type_ids: [ newer_key.type_id ])
      @world.post_types.create!(name: "diary")
      create_post(world: @world, type_name: "diary", created_at: 1.minute.from_now)
      create_post(
        world: @world,
        visible_to_key_type_ids: [ older_key.type_id ],
        hidden_from_user_ids: [ @recipient.id ],
        created_at: 2.minutes.from_now,
      )

      assert_equal [ newer_key.id, older_key.id ],
        @recipient.world_keys.with_visible_post_activity.order("latest_post_at DESC NULLS LAST").to_a.map(&:id)
    end
  end
end
