# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_keys
#
#  id           :uuid             not null, primary key
#  accepted_at  :timestamptz
#  color        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :uuid             not null
#  world_id     :uuid             not null
#
# Indexes
#
#  index_world_keys_on_accepted_at   (accepted_at)
#  index_world_keys_on_recipient_id  (recipient_id)
#  index_world_keys_on_world_id      (world_id)
#  index_world_keys_uniqueness       (world_id,recipient_id,color) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
require "test_helper"

class WorldKeyTest < ActiveSupport::TestCase
  setup do
    @world = create_world(owner: users(:bob), name: "Key Test World")
    @recipient = users(:sue)
    @recipient_device = devices(:sues_phone)
  end

  test "color is unique per recipient and world" do
    grant_key(world: @world, recipient: @recipient, color: :blue)
    duplicate = @world.keys.build(recipient: @recipient, color: :blue)

    assert_not_predicate duplicate, :valid?
    assert_includes duplicate.errors, :recipient
  end

  test "a recipient may hold multiple keys of different colors" do
    grant_key(world: @world, recipient: @recipient, color: :blue)
    second = @world.keys.build(recipient: @recipient, color: :red)

    assert_predicate second, :valid?
  end

  test "the world owner cannot be granted a key" do
    key = @world.keys.build(recipient: users(:bob), color: :blue)

    assert_not_predicate key, :valid?
    assert_includes key.errors, :recipient
  end

  test "destroying a recipient's last key discards their cards on that world" do
    key = grant_key(world: @world, recipient: @recipient, color: :blue)
    card = @world.cards.create!(
      cardholder: @recipient,
      device: @recipient_device,
      granted_key_color: :blue,
    )

    key.destroy!

    card.reload
    assert_predicate card, :discarded?
  end

  test "destroying one of several keys leaves the recipient's cards kept" do
    grant_key(world: @world, recipient: @recipient, color: :blue)
    red_key = grant_key(world: @world, recipient: @recipient, color: :red)
    card = @world.cards.create!(
      cardholder: @recipient,
      device: @recipient_device,
      granted_key_color: :red,
    )

    red_key.destroy!

    card.reload
    assert_predicate card, :kept?
  end
end
