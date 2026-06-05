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
  # == Associations ==

  belongs_to :post
  has_one :world, through: :post
  belongs_to :reactor, class_name: "User"

  sig { returns(Post) }
  def post!
    post or raise ActiveRecord::RecordNotFound, "Missing associated post"
  end

  # == Validations ==

  validates :emoji,
    presence: true,
    emoji: true,
    uniqueness: { scope: [ :post_id, :reactor_id ], message: "already added to this post" }
  validate :validate_reactor_not_post_author

  private

  # == Callbacks ==

  sig { void }
  def validate_reactor_not_post_author
    if (world = self.world) && (reactor_id = self[:reactor_id]) &&
        reactor_id == world.owner_id
      errors.add(:reactor_id, "cannot be the post author")
    end
  end
end
