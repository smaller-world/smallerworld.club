# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeyTypeTest < ActiveSupport::TestCase
  setup do
    @world = create_world(owner: users(:bob))
    @type = @world.key_types.find_by!(name: "new friends")
  end

  test "an active key blocks deletion of its type" do
    @world.keys.create!(recipient: users(:sue), type: @type)

    refute @type.destroy
    assert_predicate @type, :persisted?
    assert_equal [ :active_keys ], @type.errors.where(:base).map(&:type)
  end

  test "a pending invitation blocks deletion of its key type" do
    @world.invitations.create!(recipient: users(:sue), key_type: @type)

    refute @type.destroy
    assert_predicate @type, :persisted?
    assert_equal [ :pending_invitations ], @type.errors.where(:base).map(&:type)
  end

  test "deletion reports both active keys and pending invitations" do
    @world.keys.create!(recipient: users(:sue), type: @type)
    @world.invitations.create!(recipient: users(:jane), key_type: @type)

    refute @type.destroy
    assert_predicate @type, :persisted?
    assert_equal [ :active_keys, :pending_invitations ], @type.errors.where(:base).map(&:type)
  end
end
