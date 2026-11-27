# typed: false
# frozen_string_literal: true

require "digest/md5"
require "faker"
require "active_support/core_ext/digest/uuid"

module DevelopmentData
  USER_NAMES = %w[alex blair casey drew ellis].freeze
  POST_COUNTS = { alex: 1, blair: 60, casey: 8, drew: 3, ellis: 15 }.freeze
  KEY_TYPES = {
    blair: { alex: "existing friends", casey: "existing friends", drew: "existing friends", ellis: "existing friends" },
    casey: { alex: "new friends", blair: "chosen family" },
    drew: { casey: "new friends" },
    ellis: { blair: "chosen family", drew: "new friends" },
  }.freeze

  # Stable identities survive edits to names, phone numbers, and post content.
  def self.id(label)
    Digest::UUID.uuid_v5(Digest::UUID::URL_NAMESPACE, "smallerworld.club/development/#{label}")
  end

  def self.seed!
    raise "development data is only available in development or test" unless Rails.env.local?

    config = SmallerWorld.application.config.x
    previous = config.v1_checks_disabled
    config.v1_checks_disabled = true

    # Keep suppression active through commit, when notification callbacks run.
    Notification.suppress do
      Post.suppressing_turbo_broadcasts do
        WorldKey.suppressing_turbo_broadcasts do
          ApplicationRecord.transaction do
            users = create_users
            worlds = create_worlds(users)
            create_keys_and_invitations(users, worlds)
            create_posts(users, worlds)
            create_reactions(users, worlds)
          end
        end
      end
    end
    create_notification_examples
  ensure
    config.v1_checks_disabled = previous if config
  end

  def self.create_users
    USER_NAMES.each_with_index.to_h do |name, index|
      user = User.find_or_create_by!(id: id("user/#{name}")) do |record|
        record.assign_attributes(
          name: name.capitalize,
          phone_number: "+1416555010#{index + 1}",
          email_address: "#{name}@example.com",
          email_address_confirmed_at: Time.current,
          time_zone_name: "America/Toronto",
          app_last_visited_at: 1.day.ago,
        )
      end
      [ name.to_sym, user ]
    end
  end

  def self.create_worlds(users)
    worlds = users.to_h do |name, owner|
      [ name, create_world(name, owner, "#{owner.name.downcase}'s world") ]
    end
    worlds[:casey_second] = create_world(:casey_second, users.fetch(:casey), "casey's quiet corner")
    worlds.each do |label, world|
      starter_key_types(label).each do |type|
        next if world.key_types.exists?(id: type.id)

        world.key_types.find_or_create_by!(name: type.name) do |record|
          record.id = type.id
          record.color = type.color
        end
      end
      PostType.default_types.each do |type|
        world.post_types.find_or_create_by!(id: id("type/#{label}/#{type.name}")) do |record|
          record.name = type.name
          record.icon = type.icon
        end
      end
    end
    worlds
  end

  def self.create_world(label, owner, name)
    world = World.find_or_initialize_by(id: id("world/#{label}"))
    image = label == :casey_second ? :casey : label
    icon_path = Rails.root.join("db/seeds/images/#{image}.png")
    unless world.new_record?
      restore_world_icon(world.icon.blob, icon_path)
      return world
    end

    world.owner = owner
    world.name = name
    world.created_at = POST_COUNTS.fetch(label, 1).days.ago
    world.key_types_review_pending = label == :blair
    world.key_types = starter_key_types(label)
    world.post_types = PostType.default_types.map do |type|
      type.id = id("type/#{label}/#{type.name}")
      type
    end
    world.icon.attach(io: StringIO.new(icon_path.binread), filename: icon_path.basename.to_s, content_type: "image/png")
    world.save!
    world
  end

  def self.restore_world_icon(blob, icon_path)
    return unless blob && !blob.service.exist?(blob.key)

    bytes = icon_path.binread
    return unless Digest::MD5.base64digest(bytes) == blob.checksum

    blob.service.upload(blob.key, StringIO.new(bytes), checksum: blob.checksum)
  end

  def self.starter_key_types(label)
    types = WorldKeyType.default_types
    types << WorldKeyType.existing_friends_type if label == :blair
    types.each { |type| type.id = id("key-type/#{label}/#{type.name}") }
  end

  def self.key_type(world, label, name)
    world.key_types.find_by(id: id("key-type/#{label}/#{name}")) || world.key_types.find_by!(name:)
  end

  def self.create_keys_and_invitations(users, worlds)
    KEY_TYPES.each do |owner, recipients|
      world = worlds.fetch(owner)
      recipients.each do |recipient, name|
        world.keys.find_or_create_by!(recipient: users.fetch(recipient)) do |key|
          key.type = key_type(world, owner, name)
          key.world_last_visited_at = recipient == :blair ? Time.current : 1.week.ago
        end
      end
    end

    { casey: :ellis, drew: :blair }.each do |owner, recipient|
      world = worlds.fetch(owner)
      # Accepting an invitation locally must not make setup offer it again.
      next if world.keys.exists?(recipient: users.fetch(recipient))

      invitation = world.invitations.find_or_initialize_by(id: id("invitation/#{owner}/#{recipient}")) do |record|
        record.recipient = users.fetch(recipient)
      end
      invitation.key_type ||= key_type(world, owner, "new friends")
      invitation.save! if invitation.changed?
    end
  end

  def self.create_posts(users, worlds)
    previous_random = Faker::Config.random
    field_note = worlds.fetch(:casey).post_types.find_or_create_by!(id: id("type/field-note")) do |type|
      type.name = "field note"
      type.icon = "huge/book-edit"
    end

    worlds.each do |owner, world|
      next unless world.previously_new_record?

      intro = world.posts.sole
      intro.update!(post_audience(world, owner, intro, 0, users))
    end

    POST_COUNTS.each do |owner, count|
      world = worlds.fetch(owner)
      types = PostType.default_types.map { |type| world.post_types.find(id("type/#{owner}/#{type.name}")) }
      (1...count).each do |number|
        world.posts.find_or_create_by!(id: id("post/#{owner}/#{number}")) do |post|
          # A fresh random source per post makes filling a missing post predictable.
          Faker::Config.random = Random.new(id("post/#{owner}/#{number}").delete("-").to_i(16))
          post.type = owner == :casey && number == 7 ? field_note : types[(number - 1) % types.length]
          post.title = case [ owner, number ]
          when [ :casey, 7 ] then "field note for chosen family"
          when [ :ellis, 1 ] then "for chosen family and drew"
          when [ :ellis, count - 1 ] then "a note just for me"
          else Faker::Lorem.sentence(word_count: 4).downcase
          end
          post.body = Faker::Lorem.paragraphs(number: 2).map { |text| "<p>#{text}</p>" }.join
          post.created_at = (count - number).days.ago
          post.assign_attributes(post_audience(world, owner, post, number, users))
          post.favorited_at = Time.current if %i[blair ellis].include?(owner) && number == 1
          post.hidden_from_user_ids = [ users.fetch(:drew).id ] if owner == :blair && number == 1
        end
      end
    end
  ensure
    Faker::Config.random = previous_random
  end

  def self.post_audience(world, owner, post, number, users)
    if owner == :blair
      recipients = KEY_TYPES.fetch(:blair).keys
      recipients -= [ :alex ] unless post.type_id == id("type/blair/journal entry")
      return { visible_to_key_type_ids: [], visible_to_user_ids: recipients.map { |recipient| users.fetch(recipient).id } }
    end

    case [ owner, number ]
    when [ :ellis, POST_COUNTS.fetch(:ellis) - 1 ]
      {}
    when [ :ellis, 1 ]
      {
        visible_to_key_type_ids: [ key_type(world, owner, "chosen family").id ],
        visible_to_user_ids: [ users.fetch(:drew).id ],
      }
    else
      names = post.type_id == id("type/field-note") ? [ "chosen family" ] : WorldKeyType.default_types.map(&:name)
      { visible_to_key_type_ids: names.map { |name| key_type(world, owner, name).id } }
    end
  end

  def self.create_reactions(users, worlds)
    { blair: :casey, ellis: :drew }.each do |owner, reactor|
      post = worlds.fetch(owner).posts.find(id("post/#{owner}/1"))
      post.reactions.find_or_create_by!(reactor: users.fetch(reactor), emoji: "❤️")
    end
  end

  def self.create_notification_examples
    blair = User.find(id("user/blair"))
    casey = User.find(id("user/casey"))
    post = Post.find(id("post/blair/1"))
    reaction = post.reactions.find_by!(reactor: casey)
    key = World.find(id("world/casey")).keys.find_by!(recipient: blair)
    invitation = WorldInvitation.find(id("invitation/drew/blair"))
    [ [ post, casey, nil ], [ reaction, blair, Time.current ],
      [ key, casey, nil ], [ invitation, blair, nil ] ].each do |noticeable, recipient, received_at|
      Notification.find_or_create_by!(id: id("notification/#{noticeable.class}/#{noticeable.id}")) do |notification|
        notification.assign_attributes(noticeable:, recipient:, delivered_at: Time.current, received_at:)
      end
    end
  end
end
