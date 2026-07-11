# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_keys
#
#  id                    :uuid             not null, primary key
#  world_last_visited_at :timestamptz
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  invitation_id         :uuid
#  recipient_id          :uuid             not null
#  world_id              :uuid             not null
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
class WorldKey < ApplicationRecord
  include Noticeable

  # == Associations ==

  belongs_to :world, inverse_of: :keys
  has_many :world_invitations, through: :world, source: :invitations
  has_one :world_owner, through: :world, source: :owner
  has_many :world_post_types, through: :world, source: :post_types
  has_many :world_posts, through: :world_post_types, source: :posts

  has_many :post_type_grants, dependent: :destroy
  has_many :granted_post_types, through: :post_type_grants, source: :post_type

  belongs_to :recipient, class_name: "User"
  belongs_to :invitation,
    class_name: "WorldInvitation",
    optional: true,
    dependent: :destroy

  sig { returns(World) }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  sig { returns(User) }
  def world_owner!
    world_owner or raise ActiveRecord::RecordNotFound, "Missing world owner"
  end

  sig { returns(User) }
  def recipient!
    recipient or raise ActiveRecord::RecordNotFound, "Missing recipient"
  end

  # == Validations ==

  validates :recipient, uniqueness: {
    scope: :world,
    message: ->(object, _data) {
      world = object.world!
      "already has a key to #{world.name}"
    },
  }
  validate :validate_recipient_not_world_owner, on: :create

  # == Hooks ==

  after_initialize :set_invitation, unless: :invitation_id?
  after_create_commit :create_notification_for_world_owner!

  # == Scopes ==

  scope :order_by_latest_visible_post, -> {
    latest_post_at = Arel::Nodes::Grouping.new(
      Post
        .joins(:type)
        .where("post_types.world_id = world_id")
        .where(
          PostTypeGrant
            .where("post_type_grants.world_key_id = world_keys.id")
            .where("post_type_grants.post_type_id = posts.type_id")
            .arel
            .exists,
        )
        .where.not("world_keys.recipient_id = ANY(posts.hidden_from_ids)")
        .select("MAX(posts.created_at)")
        .arel,
    )
    select("*", latest_post_at.as("latest_post_at"))
      .order("latest_post_at DESC NULLS LAST")
  }
  scope :with_world_and_attached_icon, -> {
    includes(world: { icon_attachment: :blob })
  }

  # == Notifications ==

  sig { override.params(recipient: User).returns(Notification::Message) }
  def notification_message(recipient:)
    world = world!
    key_recipient = recipient!
    Notification::Message.new(
      target_url: [ world, :keys ],
      title: "#{key_recipient.name} joined #{world.name}!",
      world:,
    )
  end

  sig { void }
  def create_notification_for_world_owner!
    notifications.create!(recipient: world_owner!)
  end

  # == Grants ==

  sig { returns(ActiveSupport::MessageVerifier) }
  def self.grant_verifier
    Rails.application.message_verifier(:world_key_grant)
  end

  sig { params(message: String).returns(VerifiedWorldKeyGrant) }
  def self.verify_grant(message)
    VerifiedWorldKeyGrant.new(grant_verifier.verify(message))
  end

  # == Methods ==

  sig { returns(T::Boolean) }
  def record_world_visit!
    update!(world_last_visited_at: Time.current)
  end

  sig { returns(Post::PrivateAssociationRelation) }
  def new_visible_world_posts_since_last_visited
    recipient = recipient!
    scope = world_posts
    if (last_visited_at = world_last_visited_at)
      scope = scope.where("posts.created_at > ?", last_visited_at)
    end
    scope.visible_to(recipient)
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(WorldInvitation)) }
  def recipient_invitation_pending_acceptance
    recipient_phone_number = User.where(id: recipient_id).select(:phone_number)
    world_invitations.pending_acceptance
      .where(recipient_id:)
      .or(world_invitations.where(recipient_phone_number:))
      .first
  end

  # == Callbacks ==

  sig { void }
  def set_invitation
    if (invitation = recipient_invitation_pending_acceptance)
      self.invitation = invitation
    end
  end

  sig { void }
  def validate_recipient_not_world_owner
    if recipient_id == world&.owner_id
      errors.add(:recipient, "cannot be the world owner")
    end
  end

  # sig { void }
  # def discard_recipient_world_cards!
  #   world = world!
  #   recipient = recipient!
  #   world.cards.kept.where(cardholder: recipient).discard_all!
  # end
end
