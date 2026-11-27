# typed: true
# frozen_string_literal: true

require "test_helper"

# Legacy rows must bypass the current model validators to exercise the actual database boundary.
# rubocop:disable Rails/SkipsModelValidations
class KeyTypesCutoverTest < ActionDispatch::IntegrationTest
  setup do
    @db = ActiveRecord::Base.connection
    skip "requires a disposable cutover rehearsal database" unless @db.current_database.start_with?("smallerworld_cutover_rehearsal_")

    @migrations = @db.pool.migration_context
    @versions = [ 20261123000003, 20261123000004 ]
    rollback

    @world = worlds(:bobs_world_one)
    @second_world = worlds(:bobs_world_two)
    @sue = users(:sue)
    @jane = users(:jane)
    @world.update!(key_types_review_pending: true)
    @reused = @world.key_types.create!(name: "existing friends", color: "blue")
    @custom = @world.key_types.create!(name: "neighbors", color: "pink")
    @accepted = invite(@sue, @custom)
    @pending = invite(@jane, nil)
    @key = WorldKey.insert!({
      world_id: @world.id,
      recipient_id: @sue.id,
      invitation_id: @accepted.id,
      type_id: @custom.id,
    }).first.fetch("id")
    @second_key = WorldKey.insert!({ world_id: @second_world.id, recipient_id: @jane.id }).first.fetch("id")
    @type = @world.post_types.create!(name: "journal entry")
    @post = create_post(world: @world, body: "historical journal")
    @db.execute(<<~SQL.squish)
      INSERT INTO post_type_grants (world_id, world_key_id, post_type_id, created_at)
      VALUES (#{@db.quote(@world.id)}, #{@db.quote(@key)}, #{@db.quote(@type.id)}, CURRENT_TIMESTAMP)
    SQL
  end

  test "existing worlds and invitations retain identity through assignment" do
    migrate
    expected = { "chosen family" => "pink", "new friends" => "green", "acquaintances" => "blue", "existing friends" => "orange" }
    World.find_each do |world|
      assert_equal expected, world.key_types.where(name: expected.keys).pluck(:name, :color).to_h
      assert_predicate world, :key_types_review_pending?
    end
    assert_equal "pink", @custom.reload.color
    assert_equal @reused.id, WorldKey.find(@key).type_id
    assert_equal @accepted.id, WorldKey.find(@key).invitation_id
    assert_equal [ @reused.id, @reused.id ], [ @accepted.reload.key_type_id, @pending.reload.key_type_id ]
    assert_equal @second_world.key_types.find_by!(name: "existing friends").id, WorldKey.find(@second_key).type_id
    fresh = create_world(owner: users(:bob), name: "after cutover")
    assert_equal expected.except("existing friends"), fresh.key_types.pluck(:name, :color).to_h
    refute_predicate fresh, :key_types_review_pending?
  end

  test "historical selections preserve every holder's audience before moderation" do
    blocked = create_post(world: @world, hidden_from_user_ids: [ @sue.id ])
    blocked.update_columns(hidden_from_user_ids: [ @jane.id, @sue.id ])
    other = @world.post_types.create!(name: "letter")
    stale = create_post(world: @world, type_name: other.name)
    stale.update_columns(visible_to_user_ids: [ @sue.id ], visible_to_key_type_ids: [ @custom.id ])
    expected = legacy_pairs
    migrate
    assert_equal expected, Post.with_recipient_keys.order("posts.id", "world_keys.recipient_id").pluck("posts.id", "world_keys.recipient_id")
    assert_equal [ @sue.id ], @post.reload.visible_to_user_ids
    assert_equal [ @sue.id ], blocked.reload.visible_to_user_ids
    assert_equal [ @jane.id, @sue.id ], blocked.hidden_from_user_ids
    assert_empty stale.reload.visible_to_user_ids
    assert Post.all.all? { |post| post.visible_to_key_type_ids.empty? }
  end

  test "moderation suppresses and releases the migrated audience" do
    upheld = create_post(world: @world)
    dismissed = create_post(world: @world)
    pending = @post.reports.create!(reporter: @sue, category: :spam)
    upheld.reports.create!(reporter: @sue, category: :spam).resolve!(resolution: :upheld, moderator: users(:bob))
    dismissed.reports.create!(reporter: @sue, category: :spam).resolve!(resolution: :dismissed, moderator: users(:bob))
    migrate
    assert_equal [ dismissed.id ], @world.posts.visible_to(@sue).ids
    pending.resolve!(resolution: :dismissed, moderator: users(:bob))
    assert_equal [ dismissed.id, @post.id ].sort, @world.posts.visible_to(@sue).ids.sort
  end

  test "keys and invitations require a same-world type in PostgreSQL" do
    migrate
    foreign_type = @second_world.key_types.first!
    [ [ WorldKey.where(id: @key), :type_id ], [ WorldInvitation.where(id: @pending.id), :key_type_id ] ].each do |rows, column|
      assert_raises(ActiveRecord::NotNullViolation) do
        @db.transaction(requires_new: true) { rows.update_all(column => nil) }
      end
      assert_raises(ActiveRecord::InvalidForeignKey) do
        @db.transaction(requires_new: true) { rows.update_all(column => foreign_type.id) }
      end
      assert_equal 1, rows.update_all(column => @custom.id)
    end
  end

  test "the migrated pending invitation can be redeemed at its original URL" do
    migrate
    create_post(world: @world, body: "for existing friends", visible_to_key_type_ids: [ @reused.id ])
    sign_in_as(@jane)
    get world_invitation_path(@pending)
    assert_response :redirect
    follow_redirect!
    assert_response :success
    action = css_select("form#accept_world_key_grant_form").first["action"]
    post action, as: :turbo_stream
    assert_redirected_to world_path(@world)
    key = @pending.reload.world_key
    assert_equal [ @world.id, @jane.id, @reused.id ], [ key.world_id, key.recipient_id, key.type_id ]
    get world_posts_path(@world), headers: { "Turbo-Frame" => "posts" }
    assert_response :success
    assert_includes response.body, "for existing friends"
    assert_not_includes response.body, "historical journal"
  end

  test "rollback restores the full rows and nullable schema and permits replay" do
    @post.update_columns(visible_to_user_ids: [ @jane.id, @sue.id ], visible_to_key_type_ids: [ @custom.id, @reused.id ])
    tables = %w[posts post_type_grants world_keys world_invitations world_key_types worlds]
    snapshot = -> { tables.map { |table| @db.select_rows("SELECT * FROM #{table} ORDER BY id") } }
    baseline = snapshot.call
    expected = legacy_pairs
    migrate
    rollback
    assert_equal baseline, snapshot.call
    assert @db.columns(:world_keys).find { |c| c.name == "type_id" }.null
    assert @db.columns(:world_invitations).find { |c| c.name == "key_type_id" }.null
    migrate
    assert_equal expected, Post.with_recipient_keys.order("posts.id", "world_keys.recipient_id").pluck("posts.id", "world_keys.recipient_id")
  end

  private

  def legacy_pairs
    @db.select_rows(<<~SQL.squish)
      SELECT posts.id, keys.recipient_id
      FROM posts JOIN world_keys keys ON keys.world_id = posts.world_id
      WHERE EXISTS (SELECT 1 FROM post_type_grants g WHERE g.world_key_id = keys.id AND g.post_type_id = posts.type_id)
        AND NOT keys.recipient_id = ANY(posts.hidden_from_user_ids)
      ORDER BY posts.id, keys.recipient_id
    SQL
  end

  def invite(user, type)
    id = WorldInvitation.insert!({
      world_id: @world.id,
      recipient_id: user.id,
      recipient_phone_number: user.phone_number,
      key_type_id: type&.id,
    }).first.fetch("id")
    WorldInvitation.find(id)
  end

  def migrate
    @versions.each { |version| @migrations.run(:up, version) }
  end

  def rollback
    @versions.reverse_each do |version|
      @migrations.run(:down, version) if @migrations.get_all_versions.include?(version)
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
