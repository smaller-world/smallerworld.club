# typed: false
# frozen_string_literal: true

require "faker"
require "active_support/core_ext/digest/uuid"

module DevelopmentData
  NAMES = %w[alex blair casey drew ellis].freeze
  POST_COUNTS = { alex: 1, blair: 60, casey: 8, drew: 3, ellis: 15 }.freeze

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
    NAMES.each_with_index.to_h do |name, index|
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
    worlds
  end

  def self.create_world(label, owner, name)
    world = World.find_or_initialize_by(id: id("world/#{label}"))
    return world unless world.new_record?

    world.owner = owner
    world.name = name
    world.post_types = World.default_post_types.map do |type|
      type.id = id("type/#{label}/#{type.label}")
      type
    end
    image = label == :casey_second ? :casey : label
    image_bytes = Rails.root.join("db/seeds/images/#{image}.png").binread
    world.icon.attach(io: StringIO.new(image_bytes), filename: "#{image}.png", content_type: "image/png")
    world.save!
    world
  end

  def self.create_keys_and_invitations(users, worlds)
    # Each row names a world and the people who hold its keys.
    {
      blair: %i[alex casey drew ellis],
      casey: %i[alex blair],
      drew: %i[casey],
      ellis: %i[blair drew],
    }.each do |owner, recipients|
      world = worlds.fetch(owner)
      recipients.each do |recipient|
        world.keys.find_or_create_by!(recipient: users.fetch(recipient)) do |key|
          key.world_last_visited_at = recipient == :blair ? Time.current : 1.week.ago
          if owner == :blair && recipient == :ellis
            key.muted_post_type_ids = [ id("type/#{owner}/poem") ]
          end
          types = World.default_post_types.map { |type| world.post_types.find(id("type/#{owner}/#{type.label}")) }
          types = [ types.first ] if owner == :blair && recipient == :alex
          key.post_type_grants = types.map { |type| PostTypeGrant.new(post_type: type) }
        end
      end
    end

    casey = worlds.fetch(:casey)
    field_note = casey.post_types.find_or_create_by!(id: id("type/field-note")) do |type|
      type.label = "field note"
      type.icon = "huge/book-edit"
    end
    key = casey.keys.find_by!(recipient: users.fetch(:blair))
    key.post_type_grants.find_or_create_by!(post_type: field_note)

    { casey: :ellis, drew: :blair }.each do |owner, recipient|
      world = worlds.fetch(owner)
      # Accepting an invitation locally must not make setup offer it again.
      next if world.keys.exists?(recipient: users.fetch(recipient))

      world.invitations.find_or_create_by!(id: id("invitation/#{owner}/#{recipient}")) do |invitation|
        invitation.recipient = users.fetch(recipient)
        invitation.granted_post_type_ids = world.post_type_ids
      end
    end
  end

  def self.create_posts(users, worlds)
    previous_random = Faker::Config.random
    POST_COUNTS.each do |owner, count|
      world = worlds.fetch(owner)
      types = World.default_post_types.map { |type| world.post_types.find(id("type/#{owner}/#{type.label}")) }
      (1...count).each do |number|
        world.posts.find_or_create_by!(id: id("post/#{owner}/#{number}")) do |post|
          # A fresh random source per post makes filling a missing post predictable.
          Faker::Config.random = Random.new(id("post/#{owner}/#{number}").delete("-").to_i(16))
          post.type = owner == :casey && number == 7 ? world.post_types.find(id("type/field-note")) : types[(number - 1) % types.length]
          post.title = Faker::Lorem.sentence(word_count: 4).downcase
          post.body = Faker::Lorem.paragraphs(number: 2).map { |text| "<p>#{text}</p>" }.join
          post.created_at = (count - number).days.ago
          post.favorited_at = Time.current if %i[blair ellis].include?(owner) && number == 1
          post.hidden_from_ids = [ users.fetch(:drew).id ] if owner == :blair && number == 1
        end
      end
    end
  ensure
    Faker::Config.random = previous_random
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
