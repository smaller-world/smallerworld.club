# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_keys
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invitation_id :uuid
#  recipient_id  :uuid             not null
#  world_id      :uuid             not null
#
# Indexes
#
#  index_world_keys_on_invitation_id  (invitation_id)
#  index_world_keys_on_recipient_id   (recipient_id)
#  index_world_keys_on_world_id       (world_id)
#  index_world_keys_uniqueness        (world_id,recipient_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (invitation_id => world_invitations.id)
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
    @world.keys.create!(recipient: @recipient)
    duplicate = @world.keys.build(recipient: @recipient)

    assert_not_predicate duplicate, :valid?
    assert_includes duplicate.errors, :recipient
  end

  test "the world owner cannot be granted a key" do
    key = @world.keys.build(recipient: users(:bob))

    assert_not_predicate key, :valid?
    assert_includes key.errors, :recipient
  end
end
