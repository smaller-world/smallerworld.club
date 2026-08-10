# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: worlds
#
#  id                               :uuid             not null, primary key
#  blurb                            :text
#  last_imported_v1_post_created_at :timestamptz
#  name                             :string           not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  owner_id                         :uuid             not null
#
# Indexes
#
#  index_worlds_on_name_and_owner_id  (name,owner_id) UNIQUE
#  index_worlds_on_owner_id           (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
require "test_helper"

class WorldTest < ActiveSupport::TestCase
  test "create_world helper attaches an icon" do
    world = create_world(owner: users(:sue), name: "Helper World")

    assert_predicate world, :persisted?
    assert_predicate world.icon, :attached?
  end

  test "creates an intro post on create" do
    world = create_world(owner: users(:sue), name: "Intro World")

    post = world.posts.sole
    assert_equal "welcome to my smaller world!", post.title
    assert_equal "🌎", post.emoji
    assert_equal "journal entry", post.type!.label
  end

  test "defaults its name from the owner's first name" do
    world = users(:bob).owned_worlds.build

    assert_equal "Bob's world", world.name
  end

  test "name is unique per owner" do
    create_world(owner: users(:sue), name: "Duplicate World")
    duplicate = users(:sue).owned_worlds.build(name: "Duplicate World")

    assert_not_predicate duplicate, :valid?
    assert_includes duplicate.errors.full_messages.to_sentence, "Duplicate World"
  end
end
