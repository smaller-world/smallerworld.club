# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: reactions
#
#  id         :uuid             not null, primary key
#  emoji      :string           not null
#  created_at :timestamptz      not null
#  post_id    :uuid             not null
#  reactor_id :uuid             not null
#
# Indexes
#
#  index_reactions_on_post_id     (post_id)
#  index_reactions_on_reactor_id  (reactor_id)
#  index_reactions_uniqueness     (post_id,emoji,reactor_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (reactor_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Reaction < ApplicationRecord
  include Noticeable
  include ActionView::RecordIdentifier

  # == Associations ==

  belongs_to :post
  has_one :world, through: :post
  belongs_to :reactor, class_name: "User"

  sig { returns(Post) }
  def post!
    post or raise ActiveRecord::RecordNotFound, "Missing associated post"
  end

  sig { returns(World) }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  sig { returns(User) }
  def reactor!
    reactor or raise ActiveRecord::RecordNotFound, "Missing reactor"
  end

  sig { returns(T.nilable(User)) }
  def world_owner
    if (post_id = self[:post_id])
      User.joins(:posts).find_by(posts: { id: post_id })
    end
  end

  sig { returns(User) }
  def world_owner!
    world_owner or raise ActiveRecord::RecordNotFound, "Missing associated world owner"
  end

  # == Validations ==

  validates :emoji,
    presence: true,
    emoji: true,
    uniqueness: { scope: [ :post_id, :reactor_id ], message: "already added to this post" }
  validate :validate_reactor_not_post_author

  # == Hooks ==

  after_create_commit :create_notification_for_world_owner!,
    unless: :reactor_has_other_post_reactions?

  # == Noticeable ==

  sig { override.params(recipient: User).returns(Notification::Message) }
  def notification_message(recipient:)
    post = post!
    world = post.world!
    reactor = reactor!
    Notification::Message.new(
      target_url: [ world, anchor: dom_id(post) ],
      title: "#{emoji} from #{reactor.name}",
      body: "> #{post.card_snippet}",
      world:,
    )
  end

  sig { void }
  def create_notification_for_world_owner!
    notifications.create!(recipient: world_owner!)
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def reactor_has_other_post_reactions?
    Reaction.where.not(id:).exists?(post_id:, reactor_id:)
  end

  # == Callbacks ==

  sig { void }
  def validate_reactor_not_post_author
    if (world = self.world) && (reactor_id = self[:reactor_id]) &&
        reactor_id == world.owner_id
      errors.add(:reactor_id, "cannot be the post author")
    end
  end
end
