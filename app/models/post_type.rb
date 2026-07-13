# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: post_types
#
#  id         :uuid             not null, primary key
#  icon       :string
#  label      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  world_id   :uuid             not null
#
# Indexes
#
#  index_post_types_on_world_id  (world_id)
#  index_post_types_uniqueness   (world_id,label) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class PostType < ApplicationRecord
  # == Configuration ==

  DEFAULT_POST_TYPE_LABELS = T.let(
    World.default_post_types.map(&:label).freeze,
    T::Array[String],
  )

  # == Attributes ==

  sig { returns(T::Boolean) }
  def default?
    DEFAULT_POST_TYPE_LABELS.include?(label)
  end

  sig { returns(T::Boolean) }
  def custom? = !default?

  sig { returns(String) }
  def icon
    super || default_icon
  end

  sig { returns(String) }
  def default_icon
    "huge/tag-01"
  end

  # == Associations ==

  belongs_to :world
  has_many :grants, class_name: "PostTypeGrant", dependent: :destroy
  has_many :granted_world_keys, through: :grants, source: :world_key
  has_many :recipients, through: :granted_world_keys
  has_many :subscribed_world_keys,
    ->(post_type) {
      post_type = T.let(post_type, PostType)
      where.not("? = ANY(muted_post_type_ids)", post_type.id)
    },
    through: :grants,
    source: :world_key
  has_many :subscribers, through: :subscribed_world_keys, source: :recipient

  has_many :world_keys, through: :world, source: :keys
  has_many :world_key_recipients, through: :world_keys, source: :recipient
  # has_many :subscribers,
  #   ->(post_type) {
  #     merge(post_type.recipients)
  #   },
  #   through: :world_keys,
  #   source: :recipient

  has_many :posts, inverse_of: :type, foreign_key: :type_id, dependent: :destroy

  sig { returns World }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  # == Validations ==

  validates :label, presence: true, uniqueness: { scope: :world }
end
